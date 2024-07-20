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
  # - `duration`: The duration of the subscription plan.
  #               Consists of a number and a letter representing the time unit as day, week, month, or year.
  #               For example, `1w` for 1 week, `3m` for 3 months, `1y` for 1 year.
  # - `introductory_price_cents`: The introductory price of the subscription plan in cents.
  # - `introductory_duration`: The duration of the introductory price of the subscription plan.
  #
  # Example:
  #  ```
  #   plan = CoreMerchant::SubscriptionPlan.new(name_key: "basic_monthly", price_cents: 7_99)
  #   plan.save
  #  ```
  #
  class SubscriptionPlan < ActiveRecord::Base
    self.table_name = "core_merchant_subscription_plans"

    validates :name_key, presence: true, uniqueness: true
    validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
    validates :duration, presence: true, format: { with: /\A\d+[wdmy]\z/ }

    validates :introductory_price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true },
                                         allow_nil: true
    validates :introductory_duration, format: { with: /\A\d+[wdmy]\z/ }, allow_nil: true

    def name
      I18n.t(name_key, scope: "core_merchant.subscription_plans", default: name_key.humanize)
    end

    def price
      price_cents / 100.0
    end

    def introductory_price
      introductory_price_cents / 100.0 if introductory_price_cents
    end

    def duration_in_date
      date_from_duration(duration)
    end

    def introductory_duration_in_date
      date_from_duration(introductory_duration) if introductory_duration
    end

    def to_s
      "#{name} - #{price}"
    end

    private

    def date_from_duration(duration)
      case duration[-1]
      when "d"
        duration.to_i.days
      when "w"
        duration.to_i.weeks
      when "m"
        duration.to_i.months
      when "y"
        duration.to_i.years
      end
    end
  end
end
