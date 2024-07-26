# Created by: rails generate core_merchant:install

CoreMerchant.configure do |config|
  # Set the class that represents a customer in your application.
  # This class must include the CoreMerchant::CustomerBehavior module as such:
  # class User < ApplicationRecord
  #   include CoreMerchant::CustomerBehavior
  #   ...
  # end
  config.customer_class = "User"

  # Set the class that will receive subscription notifications/
  # This class must include the CoreMerchant::SubscriptionListener module.
  # class SubscriptionListener
  #   include CoreMerchant::SubscriptionListener
  #   def on_subscription_created(subscription)
  #     ...
  #   end
  #   ...
  # end
  # This class will receive notifications when a subscription is created, updated, canceled etc.
  #
  # To test notifications to this class, you can override `on_test_event_received` method
  # and call `CoreMerchant.subscription_manager.notify_test_event`.
  # config.subscription_listener_class = "SubscriptionListener"
end
