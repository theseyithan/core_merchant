# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription"
require "core_merchant/subscription_manager"

RSpec.describe CoreMerchant::SubscriptionManager do
  let(:subscription_manager) do
    CoreMerchant::SubscriptionManager.new
  end

  let(:subscription) do
    build(:subscription)
  end

  let(:subscription_plan) do
    build(:subscription_plan, name_key: "basic_monthly")
  end

  describe "renewals concern" do
    it "checks each subscription for renewals" do
      3.times do
        create(:subscription, subscription_plan: subscription_plan, status: :pending)
      end

      # Always return true from any instance of Subscription#due_for_renewal?
      allow_any_instance_of(CoreMerchant::Subscription)
        .to receive(:due_for_renewal?).and_return(true)

      expect(CoreMerchant::Subscription)
        .to receive(:find_each).and_call_original

      expect(subscription_manager)
        .to receive(:process_for_renewal).exactly(3).times

      subscription_manager.check_renewals
    end

    it "processes renewal" do
      expect(subscription).to receive(:can_transition_to_processing_renewal?).and_return(true)
      expect(subscription).to receive(:transition_to_processing_renewal).and_call_original

      expect(subscription_manager).to receive(:notify).with(subscription, :due_for_renewal)
      subscription_manager.process_for_renewal(subscription)

      expect(subscription).to be_processing_renewal
    end

    it "renews subscription when no payment is needed" do
      subscription.status = :processing_renewal

      expect(subscription).to receive(:can_transition_to_active?).and_return(true)
      expect(subscription).to receive(:transition_to_active).and_call_original

      expect(subscription_manager).to receive(:notify).with(subscription, :renewed)
      subscription_manager.no_payment_needed_for_renewal(subscription)

      expect(subscription).to be_active
    end

    it "processes payment for renewal" do
      subscription.status = :processing_renewal

      expect(subscription).to receive(:can_transition_to_processing_payment?).and_return(true)
      expect(subscription).to receive(:transition_to_processing_payment).and_call_original

      expect(subscription_manager).to receive(:notify).with(subscription, :renewal_payment_processing)
      subscription_manager.processing_payment_for_renewal(subscription)

      expect(subscription).to be_processing_payment
    end

    it "renews subscription when payment is successful" do
      subscription.status = :processing_payment

      expect(subscription).to receive(:can_transition_to_active?).and_return(true)
      expect(subscription).to receive(:transition_to_active).and_call_original

      expect(subscription_manager).to receive(:notify).with(subscription, :renewed)
      subscription_manager.payment_successful_for_renewal(subscription)

      expect(subscription).to be_active, "Subscription should be active but is #{subscription.status}"
    end

    it "expires subscription when payment fails and not in grace period" do
      subscription.status = :processing_payment

      expect(subscription).to receive(:in_grace_period?).and_return(false)
      expect(subscription).to receive(:transition_to_expired).and_call_original

      expect(subscription_manager).to receive(:notify).with(subscription, :expired)
      subscription_manager.payment_failed_for_renewal(subscription)

      expect(subscription).to be_expired, "Subscription should be expired but is #{subscription.status}"
    end

    it "sets subscription to past due when payment fails and in grace period" do
      subscription.status = :processing_payment

      expect(subscription).to receive(:in_grace_period?).and_return(true)
      expect(subscription).to receive(:transition_to_past_due).and_call_original

      subscription_manager.payment_failed_for_renewal(subscription)

      expect(subscription).to be_past_due, "Subscription should be past due but is #{subscription.status}"
    end
  end
end
