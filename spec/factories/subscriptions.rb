# frozen_string_literal: true

FactoryBot.define do
  factory :subscription, class: CoreMerchant::Subscription do
    association :customer, factory: :user
    association :subscription_plan, factory: :subscription_plan
    status { "pending" }
    start_date { 1.day.ago }
  end
end
