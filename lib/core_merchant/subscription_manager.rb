# frozen_string_literal: true

module CoreMerchant
  # Manages subscriptions in CoreMerchant.
  # This class is responsible for notifying listeners when subscription events occur.
  # Attributes:
  #   - `listeners` - An array of listeners that will be notified when subscription events occur.
  class SubscriptionManager
    attr_reader :listeners

    def initialize
      @listeners = []
    end

    def check_subscriptions
      # Check trial expirations
      # Check expirations
      # Check renewals
    end

    def add_listener(listener)
      @listeners << listener
    end

    def notify(subscription, event, **options)
      case event
      when :created
        notify_subscription_created(subscription)
      when :destroyed
        notify_subscription_destroyed(subscription)
      when :started
        notify_subscription_started(subscription)
      when :canceled
        notify_subscription_canceled(subscription, options[:reason], options[:immediate])
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

    def send_notification_to_listeners(subscription, method_name, **args)
      @listeners.each do |listener|
        listener.send(method_name, subscription, **args) if listener.respond_to?(method_name)
      end
    end
  end
end
