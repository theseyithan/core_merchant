# frozen_string_literal: true

module CoreMerchant
  # Include this module in your application to listen for subscription events.
  module SubscriptionListener
    extend ActiveSupport::Concern

    included do
      def on_test_event_received
        puts "Test event received by CoreMerchant::SubscriptionListener. Override this method in your application."
      end

      def on_subscription_created(subscription)
        puts "Subscription (#{subscription.id}) created. Override #{__method__} in your application to handle this event." # rubocop:disable Metrics/LineLength
      end

      def on_subscription_destroyed(subscription)
        puts "Subscription (#{subscription.id}) destroyed. Override #{__method__} in your application to handle this event." # rubocop:disable Metrics/LineLength
      end

      def on_subscription_started(subscription)
        puts "Subscription (#{subscription.id}) started. Override #{__method__} in your application to handle this event." # rubocop:disable Metrics/LineLength
      end

      def on_subscription_canceled(subscription, reason:, immediate:)
        puts "Subscription (#{subscription.id}) canceled with reason '#{reason}' and immediate=#{immediate}. Override #{__method__} in your application to handle this event." # rubocop:disable Metrics/LineLength
      end
    end
  end
end
