# frozen_string_literal: true

require "spec_helper"
require "core_merchant"

RSpec.describe CoreMerchant do
  include ActiveSupport::Testing::TimeHelpers

  describe "subscription management" do
    let(:subscription_plan) { create(:subscription_plan, duration: "1m", price_cents: 1000) }
    let(:subscription) do
      create(
        :subscription,
        subscription_plan: subscription_plan,
        status: :pending,
        start_date: 1.month.ago
      )
    end

    let(:other_subscription) do
      create(
        :subscription,
        subscription_plan: subscription_plan,
        status: :pending,
        start_date: Date.yesterday
      )
    end

    before do
      subscription.start
      other_subscription.start

      CoreMerchant.subscription_manager.add_listener(MySubscriptionListener.new)
    end

    after do
      CoreMerchant.subscription_manager.listeners.clear
    end

    it "notifies listeners when a subscription is due for renewal" do
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_due_for_renewal).with(subscription)
      expect_any_instance_of(MySubscriptionListener)
        .to_not receive(:on_subscription_due_for_renewal).with(other_subscription)

      CoreMerchant.subscription_manager.check_subscriptions
    end

    it "goes through the renewal process when no payment is needed" do
      expect_any_instance_of(MySubscriptionListener).to receive(:on_subscription_renewed).with(subscription)

      allow_any_instance_of(MySubscriptionListener).to receive(:on_subscription_due_for_renewal) do |_listener, sub|
        CoreMerchant.subscription_manager.no_payment_needed_for_renewal(sub)
      end

      CoreMerchant.subscription_manager.check_subscriptions

      subscription.reload

      expect(subscription).to be_active
      expect(subscription.current_period_start).to eq(Date.today)
    end

    it "goes through the renewal process when payment is successful" do
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_renewal_payment_processing).with(subscription)
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_renewed).with(subscription)

      allow_any_instance_of(MySubscriptionListener).to receive(:on_subscription_due_for_renewal) do |_, subscription|
        CoreMerchant.subscription_manager.processing_payment_for_renewal(subscription)
        CoreMerchant.subscription_manager.payment_successful_for_renewal(subscription)
      end

      CoreMerchant.subscription_manager.check_subscriptions
    end

    it "puts subscription in grace period when payment fails" do
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_renewal_payment_processing).with(subscription)
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_grace_period_started).with(subscription, days_remaining: 3)

      allow_any_instance_of(MySubscriptionListener).to receive(:on_subscription_due_for_renewal) do |_, subscription|
        CoreMerchant.subscription_manager.processing_payment_for_renewal(subscription)
        CoreMerchant.subscription_manager.payment_failed_for_renewal(subscription)
      end

      CoreMerchant.subscription_manager.check_subscriptions

      subscription.reload

      expect(subscription).to be_past_due, "Subscription should be past due but is #{subscription.status}"
    end

    it "counts down grace period days" do
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_grace_period_started).with(subscription, days_remaining: 2)

      allow_any_instance_of(MySubscriptionListener).to receive(:on_subscription_due_for_renewal) do |_, subscription|
        CoreMerchant.subscription_manager.processing_payment_for_renewal(subscription)
        CoreMerchant.subscription_manager.payment_failed_for_renewal(subscription)
      end

      travel_to subscription.current_period_end + 1.day
      CoreMerchant.subscription_manager.check_subscriptions

      subscription.reload

      expect(subscription).to be_past_due, "Subscription should be past due but is #{subscription.status}"
      expect(subscription.days_remaining_in_grace_period).to eq(2)
    end

    it "expires subscription when grace period is exceeded" do
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_renewal_payment_processing).with(subscription)
      expect_any_instance_of(MySubscriptionListener)
        .to receive(:on_subscription_expired).with(subscription)

      allow_any_instance_of(MySubscriptionListener).to receive(:on_subscription_due_for_renewal) do |_, subscription|
        CoreMerchant.subscription_manager.processing_payment_for_renewal(subscription)
        CoreMerchant.subscription_manager.payment_failed_for_renewal(subscription)
      end

      travel_to subscription.current_period_end + 4.days
      CoreMerchant.subscription_manager.check_subscriptions

      subscription.reload

      expect(subscription).to be_expired, "Subscription should be expired but is #{subscription.status}"
      expect(subscription.days_remaining_in_grace_period).to eq(0)
    end
  end
end
