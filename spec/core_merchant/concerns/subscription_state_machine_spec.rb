# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription"
require "core_merchant/concerns/subscription_state_machine"

RSpec.describe CoreMerchant::Subscription do
  let(:subscription) do
    build(:subscription)
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

  describe "state machine" do
    it "can transition from pending" do
      subscription.status = :pending
      expect(subscription.can_transition_to_active?).to eq(true)
      expect(subscription.can_transition_to_trial?).to eq(true)
      expect(subscription.can_transition_to_processing_renewal?).to eq(true)
    end

    it "can't transition from pending" do
      subscription.status = :pending
      expect(subscription.can_transition_to_past_due?).to eq(false)
      expect(subscription.can_transition_to_pending_cancellation?).to eq(false)
      expect(subscription.can_transition_to_canceled?).to eq(false)
      expect(subscription.can_transition_to_expired?).to eq(false)
      expect(subscription.can_transition_to_processing_payment?).to eq(false)
    end

    it "can transition from trial" do
      subscription.status = :trial
      expect(subscription.can_transition_to_processing_renewal?).to eq(true)
      expect(subscription.can_transition_to_active?).to eq(true)
      expect(subscription.can_transition_to_canceled?).to eq(true)
      expect(subscription.can_transition_to_pending_cancellation?).to eq(true)
      expect(subscription.can_transition_to_expired?).to eq(true)
    end

    it "can't transition from trial" do
      subscription.status = :trial
      expect(subscription.can_transition_to_pending?).to eq(false)
      expect(subscription.can_transition_to_past_due?).to eq(false)
      expect(subscription.can_transition_to_processing_payment?).to eq(false)
    end

    it "can transition from active" do
      subscription.status = :active
      expect(subscription.can_transition_to_pending_cancellation?).to eq(true)
      expect(subscription.can_transition_to_canceled?).to eq(true)
      expect(subscription.can_transition_to_expired?).to eq(true)
      expect(subscription.can_transition_to_processing_renewal?).to eq(true)
    end

    it "can't transition from active" do
      subscription.status = :active
      expect(subscription.can_transition_to_pending?).to eq(false)
      expect(subscription.can_transition_to_trial?).to eq(false)
      expect(subscription.can_transition_to_processing_payment?).to eq(false)
    end

    it "can transition from past_due" do
      subscription.status = :past_due
      expect(subscription.can_transition_to_processing_renewal?).to eq(true)
    end

    it "can't transition from past_due" do
      subscription.status = :past_due
      expect(subscription.can_transition_to_pending?).to eq(false)
      expect(subscription.can_transition_to_trial?).to eq(false)
      expect(subscription.can_transition_to_active?).to eq(false)
      expect(subscription.can_transition_to_pending_cancellation?).to eq(false)
      expect(subscription.can_transition_to_canceled?).to eq(false)
      expect(subscription.can_transition_to_expired?).to eq(false)
      expect(subscription.can_transition_to_processing_payment?).to eq(false)
    end

    it "can transition from pending_cancellation" do
      subscription.status = :pending_cancellation
      expect(subscription.can_transition_to_canceled?).to eq(true)
      expect(subscription.can_transition_to_expired?).to eq(true)
    end

    it "can't transition from pending_cancellation" do
      subscription.status = :pending_cancellation
      expect(subscription.can_transition_to_pending?).to eq(false)
      expect(subscription.can_transition_to_trial?).to eq(false)
      expect(subscription.can_transition_to_active?).to eq(false)
      expect(subscription.can_transition_to_past_due?).to eq(false)
      expect(subscription.can_transition_to_processing_renewal?).to eq(false)
      expect(subscription.can_transition_to_processing_payment?).to eq(false)
    end

    it "can transition from processing_renewal" do
      subscription.status = :processing_renewal
      expect(subscription.can_transition_to_processing_payment?).to eq(true)
      expect(subscription.can_transition_to_active?).to eq(true)
      expect(subscription.can_transition_to_expired?).to eq(true)
      expect(subscription.can_transition_to_past_due?).to eq(true)
    end

    it "can't transition from processing_renewal" do
      subscription.status = :processing_renewal
      expect(subscription.can_transition_to_pending?).to eq(false)
      expect(subscription.can_transition_to_trial?).to eq(false)
      expect(subscription.can_transition_to_pending_cancellation?).to eq(false)
      expect(subscription.can_transition_to_canceled?).to eq(false)
    end

    it "can transition from processing_payment" do
      subscription.status = :processing_payment
      expect(subscription.can_transition_to_active?).to eq(true)
      expect(subscription.can_transition_to_expired?).to eq(true)
      expect(subscription.can_transition_to_canceled?).to eq(true)
      expect(subscription.can_transition_to_past_due?).to eq(true)
    end

    it "can't transition from processing_payment" do
      subscription.status = :processing_payment
      expect(subscription.can_transition_to_pending?).to eq(false)
      expect(subscription.can_transition_to_trial?).to eq(false)
      expect(subscription.can_transition_to_pending_cancellation?).to eq(false)
      expect(subscription.can_transition_to_processing_renewal?).to eq(false)
    end

    it "can transition from canceled" do
      subscription.status = :canceled
      expect(subscription.can_transition_to_pending?).to eq(true)
      expect(subscription.can_transition_to_processing_renewal?).to eq(true)
    end

    it "can't transition from canceled" do
      subscription.status = :canceled
      expect(subscription.can_transition_to_trial?).to eq(false)
      expect(subscription.can_transition_to_active?).to eq(false)
      expect(subscription.can_transition_to_past_due?).to eq(false)
      expect(subscription.can_transition_to_pending_cancellation?).to eq(false)
      expect(subscription.can_transition_to_expired?).to eq(false)
      expect(subscription.can_transition_to_processing_payment?).to eq(false)
    end

    it "can transition from expired" do
      subscription.status = :expired
      expect(subscription.can_transition_to_pending?).to eq(true)
      expect(subscription.can_transition_to_processing_renewal?).to eq(true)
    end

    it "can't transition from expired" do
      subscription.status = :expired
      expect(subscription.can_transition_to_trial?).to eq(false)
      expect(subscription.can_transition_to_active?).to eq(false)
      expect(subscription.can_transition_to_past_due?).to eq(false)
      expect(subscription.can_transition_to_pending_cancellation?).to eq(false)
      expect(subscription.can_transition_to_canceled?).to eq(false)
      expect(subscription.can_transition_to_processing_payment?).to eq(false)
    end
  end
end
