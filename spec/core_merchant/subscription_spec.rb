# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription"
require "support/user"

RSpec.describe CoreMerchant::Subscription do
  include ActiveSupport::Testing::TimeHelpers

  let(:subscription) do
    build(:subscription)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      subscription.save
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

    it "has many subscription events" do
      expect(subscription).to respond_to(:events)
    end

    it "has many renewal events" do
      expect(subscription).to respond_to(:renewal_events)
    end

    it "has many status change events" do
      expect(subscription).to respond_to(:status_change_events)
    end

    it "has many plan change events" do
      expect(subscription).to respond_to(:plan_change_events)
    end

    it "has many cancellation events" do
      expect(subscription).to respond_to(:cancellation_events)
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
    before do
      subscription.start
    end

    it "calculates the days remaining in the current period" do
      travel_to 10.days.from_now
      expect(subscription.days_remaining_in_current_period).to eq(20)
    end

    it "returns grace period" do
      expect(subscription.grace_period).to eq(3.days)
    end

    it "returns the end of the grace period" do
      expect(subscription.grace_period_end_date).to be_within(1.second).of(subscription.current_period_end + 3.days)
    end

    it "returns in_grace_period? correctly" do
      expect(subscription.in_grace_period?).to eq(false)

      subscription.status = :past_due
      travel_to subscription.current_period_end + 2.days
      expect(subscription.in_grace_period?).to eq(true)

      travel_to subscription.current_period_end + 4.days
      expect(subscription.in_grace_period?).to eq(false)
    end

    it "returns remaining days in grace period" do
      subscription.status = :past_due
      travel_to subscription.current_period_end + 2.days
      expect(subscription.days_remaining_in_grace_period).to eq(1)
    end

    it "returns grace_period_exceeded? correctly" do
      expect(subscription.grace_period_exceeded?).to eq(false)

      subscription.status = :past_due
      travel_to subscription.current_period_end + 4.days
      expect(subscription.grace_period_exceeded?).to eq(true)
    end

    it "returns due_for_renewal? true for active subscriptions past subscription period end" do
      subscription.status = :active
      travel_to subscription.current_period_end + 1.day
      expect(subscription.due_for_renewal?).to eq(true)
    end

    it "returns due_for_renewal? false for active subscriptions before subscription period end" do
      subscription.status = :active
      travel_to subscription.current_period_end - 1.day
      expect(subscription.due_for_renewal?).to eq(false)
    end

    it "returns due_for_renewal? true for past due subscriptions" do
      subscription.status = :past_due
      travel_to subscription.current_period_end + 1.day
      expect(subscription.due_for_renewal?).to eq(true)
    end

    it "returns due_for_renewal? false for expired subscriptions" do
      subscription.status = :expired
      travel_to subscription.current_period_end + 1.day
      expect(subscription.due_for_renewal?).to eq(false)
    end

    it "returns expired_or_canceled? true for expired subscriptions" do
      subscription.status = :expired
      expect(subscription.expired_or_canceled?).to eq(true)
    end

    it "returns expired_or_canceled? true for canceled subscriptions" do
      subscription.status = :canceled
      expect(subscription.expired_or_canceled?).to eq(true)
    end

    it "returns expired_or_canceled? false for active subscriptions" do
      subscription.status = :active
      expect(subscription.expired_or_canceled?).to eq(false)
    end

    it "returns processing? true for renewal processing subscriptions" do
      subscription.status = :processing_renewal
      expect(subscription.processing?).to eq(true)
    end

    it "returns processing? true for payment processing subscriptions" do
      subscription.status = :processing_payment
      expect(subscription.processing?).to eq(true)
    end

    it "returns processing? false for active subscriptions" do
      subscription.status = :active
      expect(subscription.processing?).to eq(false)
    end

    it "returns processing? false for expired subscriptions" do
      subscription.status = :expired
      expect(subscription.processing?).to eq(false)
    end
  end

  describe "logic" do
    it "starts the subscription" do
      subscription.start
      expect(subscription).to be_active
      expect(subscription.current_period_start).to eq(Date.yesterday)
      expect(subscription.current_period_end).to eq(Date.yesterday + 1.month)
    end

    it "cancels the subscription at period end" do
      subscription.start
      subscription.cancel(reason: "Too expensive", at_period_end: true)
      expect(subscription).to be_pending_cancellation
      expect(subscription.canceled_at).to eq(Date.yesterday + 1.month)
      expect(subscription.cancellation_reason).to eq("Too expensive")
    end

    it "cancels the subscription immediately" do
      subscription.start
      subscription.cancel(reason: "Too expensive", at_period_end: false)
      expect(subscription).to be_canceled
      expect(subscription.canceled_at).to be_within(1.second).of(Time.current)
      expect(subscription.cancellation_reason).to eq("Too expensive")
    end

    it "starts a new period" do
      subscription.start
      travel_to subscription.current_period_end
      subscription.start_new_period

      expect(subscription.current_period_start).to eq(Date.today)
      expect(subscription.current_period_end).to eq(Date.today + 1.month)
    end
  end

  describe "scopes" do
    it "returns subscriptions due for renewal" do
      plan = create(:subscription_plan, duration: "1m")

      3.times do
        create(:subscription, start_date: Date.yesterday, subscription_plan: plan).start
      end

      3.times do
        create(:subscription, start_date: Date.today + 1.week, subscription_plan: plan).start
      end

      travel_to Date.today + 1.month
      expect(CoreMerchant::Subscription.due_for_renewal.count).to eq(3)
    end
  end
end
