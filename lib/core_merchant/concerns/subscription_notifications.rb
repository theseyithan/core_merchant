# frozen_string_literal: true

require "active_support/concern"

module CoreMerchant
  module Concerns
    # Includes logic for notifying the SubscriptionManager when a subscription is created or destroyed,
    # as well as providing a hook for custom notification logic.
    module SubscriptionNotifications
      extend ActiveSupport::Concern

      included do
        # Notify SubscriptionManager on creation and destruction.
        after_create { notify_subscription_manager(:created) }
        after_destroy { notify_subscription_manager(:destroyed) }

        def notify_subscription_manager(event)
          CoreMerchant.subscription_manager.notify(self, event)
        end
      end
    end
  end
end
