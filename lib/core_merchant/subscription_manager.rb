# frozen_string_literal: true

module CoreMerchant
  # Manages subscriptions in CoreMerchant.
  class SubscriptionManager
    attr_reader :listeners

    def initialize
      @listeners = []
    end

    def add_listener(listener)
      @listeners << listener
    end

    def notify_test_event
      @listeners.each do |listener|
        listener.on_test_event_received if listener.respond_to?(:on_test_event_received)
      end
    end
  end
end
