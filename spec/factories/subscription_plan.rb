# frozen_string_literal: true

FactoryBot.define do
  factory :subscription_plan do
    trait :basic do
      name_key { "Basic" }
      price { 9_99 }
      duration { "1m" }
    end

    trait :premium do
      name_key { "Premium" }
      price { 19_99 }
      duration { "1m" }
    end
  end
end
