# frozen_string_literal: true

FactoryBot.define do
  factory :subscription_event, class: CoreMerchant::SubscriptionEvent do
    association :subscription, factory: :subscription

    event_type { :test }
    message { "Subscription is being tested" }

    trait :renewal do
      event_type { :renewal }
      metadata { { price_cents: 9_99, renewed_until: 1.month.from_now } }
    end

    trait :status_change do
      event_type { :status_change }
      metadata { { from_status: :active, to_status: :expired } }
    end

    trait :plan_change do
      event_type { :plan_change }
      metadata { { from_plan_id: 1, to_plan_id: 2 } }
    end

    trait :cancellation do
      event_type { :cancellation }
      metadata { { at_period_end: true, reason: "No longer needed" } }
    end
  end
end
