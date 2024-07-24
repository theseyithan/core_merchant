# frozen_string_literal: true

require "core_merchant/concerns/subscription_manager_renewals"

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
    include Concerns::SubscriptionManagerRenewals

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

    def send_notification_to_listeners(subscription, method_name, **args)
      @listeners.each do |listener|
        listener.send(method_name, subscription, **args) if listener.respond_to?(method_name)
      end
    end
  end
end
