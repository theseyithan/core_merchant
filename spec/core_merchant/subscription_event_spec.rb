# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription"
require "core_merchant/subscription_event"

RSpec.describe CoreMerchant::SubscriptionEvent do
  let(:subscription_event) do
    build(:subscription_event)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      subscription_event.save
      expect(subscription_event).to be_valid, "Event is not valid: #{subscription_event.errors.full_messages}"
    end

    it "is invalid without an event type" do
      subscription_event.event_type = nil
      expect(subscription_event).to_not be_valid
    end
  end

  describe "associations" do
    it "belongs to a subscription" do
      expect(subscription_event).to respond_to(:subscription)
    end
  end

  describe "renewal event" do
    let(:renewal_event) do
      build(:subscription_event, :renewal).becomes(CoreMerchant::SubscriptionRenewalEvent)
    end

    it "has a price in cents" do
      expect(renewal_event.price_cents).to eq(9_99)
    end

    it "has a renewal date" do
      expect(renewal_event.renewed_from).to eq(Date.today)
    end

    it "has a renewed until date" do
      expect(renewal_event.renewed_until).to eq(1.month.from_now.to_date)
    end
  end

  describe "status change event" do
    let(:status_change_event) do
      build(:subscription_event, :status_change).becomes(CoreMerchant::SubscriptionStatusChangeEvent)
    end

    it "has a from status" do
      expect(status_change_event.from).to eq("active")
    end

    it "has a to status" do
      expect(status_change_event.to).to eq("expired")
    end
  end

  describe "plan change event" do
    let(:plan_change_event) do
      create(:subscription_plan, id: 1, name_key: "basic_monthly")
      create(:subscription_plan, id: 2, name_key: "premium_monthly")

      build(:subscription_event, :plan_change).becomes(CoreMerchant::SubscriptionPlanChangeEvent)
    end

    it "has a from plan" do
      expect(plan_change_event.from_plan).to be_a(CoreMerchant::SubscriptionPlan)
    end

    it "has a to plan" do
      expect(plan_change_event.to_plan).to be_a(CoreMerchant::SubscriptionPlan)
    end
  end

  describe "cancellation event" do
    let(:cancellation_event) do
      build(:subscription_event, :cancellation).becomes(CoreMerchant::SubscriptionCancellationEvent)
    end

    it "has a canceled at date" do
      expect(cancellation_event.canceled_at).to eq(cancellation_event.created_at)
    end
  end

  describe "metadata" do
    it "serializes metadata as JSON" do
      subscription_event.metadata = { message: "Events are fun!" }
      expect(subscription_event.metadata).to eq("message" => "Events are fun!")
    end
  end
end
