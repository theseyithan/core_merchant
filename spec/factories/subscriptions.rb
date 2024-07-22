# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    association :customer, factory: :user
    association :plan, factory: :subscription_plan

    status { "active" }
  end
end
