# frozen_string_literal: true

module CoreMerchant
  # Represents a subscription plan in CoreMerchant.
  # Subscription plans are used to define the pricing and features of a subscription.
  # All prices are in cents.
  #
  # Attributes:
  # - `name_key`: A unique key for the subscription plan.
  #             This key is used to identify the plan in the application,
  #             as well as the translation key for the plan name through `core_merchant.subscription_plans`.
  # - `price_cents`: The price of the subscription plan in cents.
  #
  # Example:
  #  ```
  #   plan = CoreMerchant::SubscriptionPlan.new(name_key: "basic.monthly", price_cents: 7_99)
  #   plan.save
  #  ```
  #
  class SubscriptionPlan < ActiveRecord::Base
    self.table_name = "core_merchant_subscription_plans"
    validates :name_key, presence: true, uniqueness: true
    validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def name
      I18n.t(name_key, scope: "core_merchant.subscription_plans", default: name_key.humanize)
    end

    def price
      price_cents / 100.0
    end

    def to_s
      "#{name} - #{price}"
    end
  end
end
