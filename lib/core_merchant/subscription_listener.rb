# frozen_string_literal: true

module CoreMerchant
  # Include this module in your application to listen for subscription events.
  module SubscriptionListener
    extend ActiveSupport::Concern

    included do
      def on_test_event_received
        puts "Test event received by CoreMerchant::SubscriptionListener. Override this method in your application."
      end
    end
  end
end
