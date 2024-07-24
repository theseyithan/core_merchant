# frozen_string_literal: true

module CoreMerchant
  module Concerns
    # Includes logic for renewal processing, grace period handling, and expiration checking.
    module SubscriptionManagerRenewals
      extend ActiveSupport::Concern

      included do # rubocop:disable Metrics/BlockLength
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

        private

        def renew_subscription(subscription)
          return unless subscription.transition_to_active

          subscription.start_new_period
          notify(subscription, :renewed)
        end
      end
    end
  end
end
