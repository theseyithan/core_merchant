# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription"
require "core_merchant/subscription_event"
require "core_merchant/concerns/subscription_event_association"

RSpec.describe CoreMerchant::Subscription do
  let(:subscription) do
    create(:subscription)
  end

  describe "event associations" do
    it "can create an arbitrary event" do
      subscription.events.create!(event_type: :custom, metadata: { custom: "data" })
      expect(subscription.events.count).to eq(1)
    end

    it "can retrieve arbitrary events" do
      subscription.events.create!(event_type: :custom, metadata: { custom: "data" })
      expect(subscription.events.first.metadata["custom"]).to eq("data")
    end

    it "can create a renewal event" do
      subscription.renewal_events.create!(price_cents: 9_99)
      expect(subscription.renewal_events.count).to eq(1)
    end

    it "can retrieve renewal events" do
      subscription.renewal_events.create!(price_cents: 9_99, renewed_from: Date.today,
                                          renewed_until: 1.month.from_now.to_date)

      event = subscription.renewal_events.first
      expect(event.price_cents).to eq(9_99)
      expect(event.renewed_from).to eq(Date.today)
      expect(event.renewed_until).to eq(1.month.from_now.to_date)
    end

    it "can create a status change event" do
      subscription.status_change_events.create!(from: :active, to: :expired)
      expect(subscription.status_change_events.count).to eq(1)
    end

    it "can retrieve status change events" do
      subscription.status_change_events.create!(from: :active, to: :expired)

      expect(subscription.status_change_events.first.from).to eq("active")
      expect(subscription.status_change_events.first.to).to eq("expired")
    end

    it "can create a plan change event" do
      basic = create(:subscription_plan, name_key: "basic_monthly")
      premium = create(:subscription_plan, name_key: "premium_monthly")
      subscription.plan_change_events.create!(from_plan: basic, to_plan: premium)
      expect(subscription.plan_change_events.count).to eq(1)
    end

    it "can retrieve plan change events" do
      basic = create(:subscription_plan, name_key: "basic_monthly")
      premium = create(:subscription_plan, name_key: "premium_monthly")
      subscription.plan_change_events.create!(from_plan: basic, to_plan: premium)

      expect(subscription.plan_change_events.first.from_plan).to eq(basic)
      expect(subscription.plan_change_events.first.to_plan).to eq(premium)
    end

    it "can create a cancellation event" do
      subscription.cancellation_events.create!(reason: "Too expensive", at_period_end: true)
      expect(subscription.cancellation_events.count).to eq(1)
    end

    it "can retrieve cancellation events" do
      subscription.cancellation_events.create!(reason: "Too expensive", at_period_end: true)

      event = subscription.cancellation_events.first
      expect(event.reason).to eq("Too expensive")
      expect(event.at_period_end?).to eq(true)
      expect(event.canceled_at).to be_within(1.second).of(Time.current)
    end

    it "logs an event when a subscription is started" do
      subscription.save
      subscription.start
      expect(subscription.events.count).to eq(1)

      event = subscription.status_change_events.first
      expect(event.event_type).to eq("status_change")
      expect(event.from).to eq("pending")
      expect(event.to).to eq("active")
    end

    it "logs an event when a subscription is canceled" do
      subscription.save
      subscription.start
      subscription.cancel(reason: "Too expensive", at_period_end: true)
      # pending -> active, active -> pending_cancellation: 2 status change + 1 cancellation
      expect(subscription.events.count).to eq(3)
      expect(subscription.status_change_events.count).to eq(2)
      expect(subscription.cancellation_events.count).to eq(1)

      event = subscription.cancellation_events.first
      expect(event.event_type).to eq("cancellation")
      expect(event.reason).to eq("Too expensive")
      expect(event.at_period_end?).to eq(true)
    end

    it "logs an event when a subscription is renewed" do
      subscription.save
      subscription.start

      CoreMerchant.subscription_manager.process_for_renewal(subscription)
      CoreMerchant.subscription_manager.no_payment_needed_for_renewal(subscription)

      # pending -> active, active -> processing_renewal, processing_renewal -> active: 3 status change + 1 renewal
      expect(subscription.events.count).to eq(4)
      expect(subscription.status_change_events.count).to eq(3)
      expect(subscription.renewal_events.count).to eq(1)

      event = subscription.renewal_events.first
      expect(event.event_type).to eq("renewal")
      expect(event.price_cents).to eq(subscription.subscription_plan.price_cents)
      expect(event.renewed_from).to eq(subscription.current_period_start)
      expect(event.renewed_until).to eq(subscription.current_period_end)
    end
  end
end
