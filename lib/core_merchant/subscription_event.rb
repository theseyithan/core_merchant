# frozen_string_literal: true

module CoreMerchant
  # Subscription event model
  class SubscriptionEvent < ActiveRecord::Base
    self.table_name = "core_merchant_subscription_events"

    belongs_to :subscription, class_name: "CoreMerchant::Subscription"

    validates :event_type, presence: true
  end
end
