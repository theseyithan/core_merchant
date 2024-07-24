# frozen_string_literal: true

require "core_merchant/concerns/subscription_manager_notifications"

module CoreMerchant
  # Manages subscriptions in CoreMerchant.
  # This class is responsible for notifying listeners when subscription events
  # occur and checking for and handling renewals.
  # **Attributes**:
  #   - `listeners` - An array of listeners that will be notified when subscription events occur.
  #
  # **Methods**:
  #  - `check_subscriptions` - Checks all subscriptions for renewals
  #  - `add_listener(listener)` - Adds a listener to the list of listeners
  #  - `no_payment_needed_for_renewal(subscription)` - Handles the case where no payment is needed for a renewal.
  #     Call when a subscription is renewed without payment.
  #  - `processing_payment_for_renewal(subscription)` - Handles the case where payment is being processed for a renewal.
  #     Call when payment is being processed for a renewal.
  #  - `payment_successful_for_renewal(subscription)` - Handles the case where payment was successful for a renewal.
  #     Call when payment was successful for a renewal.
  #  - `payment_failed_for_renewal(subscription)` - Handles the case where payment failed for a renewal.
  #     Call when payment failed for a renewal.
  #
  # **Usage**:
  #  ```ruby
  #  manager = CoreMerchant.subscription_manager
  #  manager.check_subscriptions
  #
  #  # ... somewhere else in the code ...
  #  manager.payment_successful_for_renewal(subscription1)
  #  manager.payment_failed_for_renewal(subscription2)
  #  ```
  #
  class SubscriptionManager
    include Concerns::SubscriptionManagerNotifications

    attr_reader :listeners

    def initialize
      @listeners = []
    end

    def check_subscriptions
      check_renewals
      check_cancellations
    end

    def add_listener(listener)
      @listeners << listener
    end

    def check_renewals
      Subscription.find_each do |subscription|
        process_for_renewal(subscription) if subscription.due_for_renewal?
      end
    end

    def process_for_renewal(subscription)
      return unless subscription.transition_to_processing_renewal

      notify(subscription, :due_for_renewal)
    end

    def no_payment_needed_for_renewal(subscription)
      renew_subscription(subscription)
    end

    def processing_payment_for_renewal(subscription)
      return unless subscription.transition_to_processing_payment

      notify(subscription, :renewal_payment_processing)
    end

    def payment_successful_for_renewal(subscription)
      renew_subscription(subscription)
    end

    def payment_failed_for_renewal(subscription)
      is_in_grace_period = subscription.in_grace_period?
      if is_in_grace_period
        subscription.transition_to_past_due
        notify(subscription, :grace_period_started, days_remaining: subscription.days_remaining_in_grace_period)
      else
        subscription.transition_to_expired
        notify(subscription, :expired)
      end
    end

    def check_cancellations
      Subscription.find_each do |subscription|
        process_for_cancellation(subscription) if subscription.pending_cancellation?
      end
    end

    def process_for_cancellation(subscription)
      return unless subscription.transition_to_expired

      notify(subscription, :expired)
    end

    private

    def renew_subscription(subscription)
      return unless subscription.transition_to_active

      subscription.start_new_period
      notify(subscription, :renewed)
    end

    def send_notification_to_listeners(subscription, method_name, **args)
      @listeners.each do |listener|
        listener.send(method_name, subscription, **args) if listener.respond_to?(method_name)
      end
    end
  end
end
