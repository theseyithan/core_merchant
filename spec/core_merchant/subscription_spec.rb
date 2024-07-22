# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription"
require "support/user"

RSpec.describe CoreMerchant::Subscription do
  let(:subscription) do
    CoreMerchant::Subscription.new(
      customer: user,
      subscription_plan: plan,
      status: :pending,
      start_date: 1.day.ago
    )
  end

  let(:user) do
    User.new(name: "John Doe", email: "john@example.com")
  end

  let(:plan) do
    CoreMerchant::SubscriptionPlan.new(
      name_key: "basic_monthly",
      price_cents: 9_99,
      duration: "1m"
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subscription).to be_valid
    end

    it "is invalid without a customer" do
      subscription.customer = nil
      expect(subscription).to_not be_valid
    end

    it "is invalid without a subscription plan" do
      subscription.subscription_plan = nil
      expect(subscription).to_not be_valid
    end

    it "is invalid without a status" do
      subscription.status = nil
      expect(subscription).to_not be_valid
    end

    it "is invalid with an invalid status" do
      # Assert throws an error if the status is not valid
      expect { subscription.status = :invalid }.to raise_error(ArgumentError)
    end

    it "is invalid without a start date" do
      subscription.start_date = nil
      expect(subscription).to_not be_valid
    end

    it "is invalid with a canceled at date without a cancellation reason" do
      subscription.canceled_at = 1.day.ago
      expect(subscription).to_not be_valid
    end

    it "is invalid with an end date before the start date" do
      subscription.end_date = 2.days.ago
      expect(subscription).to_not be_valid
    end
  end

  describe "associations" do
    it "belongs to a customer" do
      expect(subscription).to respond_to(:customer)
    end

    it "belongs to a subscription plan" do
      expect(subscription).to respond_to(:subscription_plan)
    end
  end

  describe "persistence" do
    it "can be saved" do
      expect { subscription.save }.to change(CoreMerchant::Subscription, :count).by(1)
    end

    it "can be updated" do
      subscription.save
      subscription.update(status: :canceled)
      expect(subscription.reload.status).to eq("canceled")
    end

    it "can be retrieved" do
      subscription.save
      expect(CoreMerchant::Subscription.find(subscription.id)).to eq(subscription)
    end

    it "can be destroyed" do
      subscription.save
      expect { subscription.destroy }.to change(CoreMerchant::Subscription, :count).by(-1)
    end
  end

  describe "calculate attributes" do
  end

  describe "logic" do
    it "starts the subscription" do
      subscription.start
      expect(subscription).to be_active
      expect(subscription.current_period_start).to be_within(1.second).of(1.day.ago)
      expect(subscription.current_period_end).to be_within(1.second).of(1.day.ago + 1.month)
    end

    it "cancels the subscription at period end" do
      subscription.start
      subscription.cancel(reason: "Too expensive", at_period_end: true)
      expect(subscription).to be_pending_cancellation
      expect(subscription.canceled_at).to be_within(1.second).of(1.day.ago + 1.month)
      expect(subscription.cancellation_reason).to eq("Too expensive")
    end

    it "cancels the subscription immediately" do
      subscription.start
      subscription.cancel(reason: "Too expensive", at_period_end: false)
      expect(subscription).to be_canceled
      expect(subscription.canceled_at).to be_within(1.second).of(Time.current)
      expect(subscription.cancellation_reason).to eq("Too expensive")
    end
  end
end
