# frozen_string_literal: true

module CoreMerchant
  # Include this module in your application to listen for subscription events.
  module SubscriptionListener
    extend ActiveSupport::Concern

    included do # rubocop:disable Metrics/BlockLength
      def on_test_event_received
        puts "Test event received by CoreMerchant::SubscriptionListener. Override this method in your application."
      end

      # rubocop:disable Metrics/LineLength

      def on_subscription_created(subscription)
        puts "Subscription (#{subscription.id}) created. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_destroyed(subscription)
        puts "Subscription (#{subscription.id}) destroyed. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_started(subscription)
        puts "Subscription (#{subscription.id}) started. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_canceled(subscription, reason:, immediate:)
        puts "Subscription (#{subscription.id}) canceled with reason '#{reason}' and immediate=#{immediate}. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_due_for_renewal(subscription)
        puts "Subscription (#{subscription.id}) is due for renewal. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_grace_period_(subscription, days_remaining)
        puts "Subscription (#{subscription.id}) has entered a grace period with #{days_remaining} days remaining. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_renewed(subscription)
        puts "Subscription (#{subscription.id}) renewed. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_renewal_payment_processing(subscription)
        puts "Subscription (#{subscription.id}) renewal payment processing. Override #{__method__} in your application to handle this event."
      end

      def on_subscription_expired(subscription)
        puts "Subscription (#{subscription.id}) expired. Override #{__method__} in your application to handle this event."
      end

      # rubocop:enable Metrics/LineLength
    end
  end
end
