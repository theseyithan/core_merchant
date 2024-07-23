# frozen_string_literal: true

require "core_merchant/concerns/subscription_state_machine"
require "core_merchant/concerns/subscription_notifications"

module CoreMerchant
  # Represents a subscription in CoreMerchant.
  # This class manages the lifecycle of a customer's subscription to a specific plan.
  #
  # **Subscriptions can transition through various statuses**:
  # - `pending`: Subscription created but not yet started
  # - `trial`: In a trial period
  # - `active`: Currently active and paid
  # - `past_due`: Payment failed but in grace period
  # - `pending_cancellation`: Will be canceled at period end
  # - `canceled`: Canceled by user or due to payment failure
  # - `expired`: Subscription period ended
  # - `paused`: Temporarily halted, not yet implemented
  # - `pending_change`: Plan change scheduled for next renewal, not yet implemented
  #
  # **Key features**:
  # - Supports immediate and end-of-period cancellations
  # - Allows plan changes, effective immediately or at next renewal
  # - Handles subscription pausing and resuming
  # - Manages trial periods
  # - Supports variable pricing for renewals
  #
  # **Attributes**:
  # - `customer`: Polymorphic association to the customer
  # - `subscription_plan`: The current plan for this subscription
  # - `status`: Current status of the subscription (see enum definition)
  # - `start_date`: When the subscription started
  # - `end_date`: When the subscription ended (or will end)
  # - `trial_end_date`: End date of the trial period (if applicable)
  # - `canceled_at`: When the subscription was canceled
  # - `current_period_start`: Start of the current billing period
  # - `current_period_end`: End of the current billing period
  # - `pause_start_date`: When the subscription was paused
  # - `pause_end_date`: When the paused subscription will resume
  # - `current_period_price_cents`: Price for the current period
  # - `next_renewal_price_cents`: Price for the next renewal (if different from plan)
  # - `cancellation_reason`: Reason for cancellation (if applicable)
  #
  # **Usage**:
  #  ```ruby
  #   subscription = CoreMerchant::Subscription.create(customer: user, subscription_plan: plan, status: :active)
  #   subscription.cancel(reason: "Too expensive", at_period_end: true)
  #   subscription.change_plan(new_plan, at_period_end: false)
  #   subscription.pause(until_date: 1.month.from_now)
  #   subscription.resume
  #   subscription.renew(price_cents: 1999)
  #   ```
  class Subscription < ActiveRecord::Base
    include CoreMerchant::Concerns::SubscriptionStateMachine
    include CoreMerchant::Concerns::SubscriptionNotifications

    self.table_name = "core_merchant_subscriptions"

    belongs_to :customer, polymorphic: true
    belongs_to :subscription_plan

    enum status: {
      pending: 0,
      trial: 1,
      active: 2,
      past_due: 3,
      pending_cancellation: 4,
      canceled: 5,
      expired: 6,
      paused: 7, # Logic not yet implemented
      pending_change: 8 # Logic not yet implemented
    }

    validates :customer, :subscription_plan, :status, :start_date, presence: true
    validates :status, inclusion: { in: statuses.keys }
    validate :end_date_after_start_date, if: :end_date
    validate :canceled_at_with_reason, if: :canceled_at

    # Starts the subscription.
    # Sets the current period start and end dates based on the plan's duration.
    def start
      new_period_start = start_date
      new_period_end = new_period_start + subscription_plan.duration_in_date

      transaction do
        transition_to_active!
        update!(
          current_period_start: new_period_start,
          current_period_end: new_period_end
        )
      end

      notify_subscription_manager(:started)
    end

    # Cancels the subscription.
    # Parameters:
    # - `reason`: Reason for cancellation
    # - `at_period_end`: If true, the subscription will be canceled at the end of the current period.
    #   Otherwise, the subscription will be canceled immediately.
    #   Default is `true`.
    def cancel(reason:, at_period_end: true)
      transaction do
        if at_period_end
          transition_to_pending_cancellation!
        else
          transition_to_canceled!
        end
        update!(
          canceled_at: at_period_end ? current_period_end : Time.current,
          cancellation_reason: reason
        )
      end

      notify_subscription_manager(:canceled, reason: reason, immediate: !at_period_end)
    end

    # Returns the days remaining in the current period.
    # Use to show the user how many days are left before the next renewal or
    # to refund pro-rated amounts for early cancellations.
    def days_remaining_in_current_period
      (current_period_end.to_date - Time.current.to_date).to_i
    end

    # Returns the number of days as a grace period for past-due subscriptions.
    # By default, this is 3 days.
    def grace_period
      3.days
    end

    def grace_period_end_date
      current_period_end + grace_period
    end

    def in_grace_period?
      past_due? && Time.current <= grace_period_end_date
    end

    def grace_period_remaining_days
      return 0 unless past_due?

      (grace_period_end_date.to_date - Time.current.to_date).to_i
    end

    def grace_period_exceeded?
      past_due? && Time.current > grace_period_end_date
    end

    private

    def end_date_after_start_date
      errors.add(:end_date, "must be after the `start date") if end_date <= start_date
    end

    def canceled_at_with_reason
      errors.add(:cancellation_reason, "must be present when `canceled_at` is set") if cancellation_reason.blank?
    end
  end
end
