# frozen_string_literal: true

module CoreMerchant
  module Concerns
    # Includes logic for notifying listeners of subscription events.
    module SubscriptionManagerNotifications
      extend ActiveSupport::Concern

      included do # rubocop:disable Metrics/BlockLength
        def notify(subscription, event, **options) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
          case event
          when :created
            notify_subscription_created(subscription)
          when :destroyed
            notify_subscription_destroyed(subscription)
          when :started
            notify_subscription_started(subscription)
          when :canceled
            notify_subscription_canceled(subscription, options[:reason], options[:immediate])
          when :due_for_renewal
            notify_subscription_due_for_renewal(subscription)
          when :renewed
            notify_subscription_renewed(subscription)
          when :renewal_payment_processing
            notify_subscription_renewal_payment_processing(subscription)
          when :grace_period_started
            notify_subscription_grace_period_started(subscription, options[:days_remaining])
          when :expired
            notify_subscription_expired(subscription)
          end
        end

        def notify_test_event
          send_notification_to_listeners(nil, :on_test_event_received)
        end

        private

        def notify_subscription_created(subscription)
          send_notification_to_listeners(subscription, :on_subscription_created)
        end

        def notify_subscription_destroyed(subscription)
          send_notification_to_listeners(subscription, :on_subscription_destroyed)
        end

        def notify_subscription_started(subscription)
          send_notification_to_listeners(subscription, :on_subscription_started)
        end

        def notify_subscription_canceled(subscription, reason, immediate)
          send_notification_to_listeners(subscription, :on_subscription_canceled, reason: reason, immediate: immediate)
        end

        def notify_subscription_due_for_renewal(subscription)
          send_notification_to_listeners(subscription, :on_subscription_due_for_renewal)
        end

        def notify_subscription_renewed(subscription)
          send_notification_to_listeners(subscription, :on_subscription_renewed)
        end

        def notify_subscription_renewal_payment_processing(subscription)
          send_notification_to_listeners(subscription, :on_subscription_renewal_payment_processing)
        end

        def notify_subscription_expired(subscription)
          send_notification_to_listeners(subscription, :on_subscription_expired)
        end

        def notify_subscription_grace_period_started(subscription, days_remaining)
          send_notification_to_listeners(
            subscription, :on_subscription_grace_period_started,
            days_remaining: days_remaining
          )
        end
      end
    end
  end
end
