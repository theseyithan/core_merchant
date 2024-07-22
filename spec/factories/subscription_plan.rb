# frozen_string_literal: true

FactoryBot.define do
  factory :subscription_plan, class: CoreMerchant::SubscriptionPlan do
    sequence(:id) { |n| n }
    name_key { "Example" }
    price_cents { 9_99 }
    duration { "1m" }

    trait :basic do
      name_key { "Basic" }
    end

    trait :premium do
      name_key { "Premium" }
      price_cents { 119_99 }
      duration { "1y" }
    end
  end
end
