# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription_manager"
require "support/my_subscription_listener"

RSpec.describe CoreMerchant::SubscriptionManager do
  let(:manager) do
    CoreMerchant::SubscriptionManager.new
  end

  it "has no listeners by default" do
    expect(manager.listeners).to be_empty
  end

  it "can add listeners" do
    listener = MySubscriptionListener.new
    manager.add_listener(listener)
    expect(manager.listeners).to eq([listener])
  end

  describe "notifications" do
    let(:listener) do
      MySubscriptionListener.new
    end

    before do
      manager.add_listener(listener)
    end

    it "sends the test event" do
      expect(listener).to receive(:on_test_event_received)
      manager.notify_test_event
    end

    it "sends the subscription created event" do
      subscription = double("subscription")
      expect(listener).to receive(:on_subscription_created).with(subscription)
      manager.notify(subscription, :created)
    end

    it "sends the subscription destroyed event" do
      subscription = double("subscription")
      expect(listener).to receive(:on_subscription_destroyed).with(subscription)
      manager.notify(subscription, :destroyed)
    end

    it "sends the subscription started event" do
      subscription = double("subscription")
      expect(listener).to receive(:on_subscription_started).with(subscription)
      manager.notify(subscription, :started)
    end

    it "sends the subscription canceled event" do
      subscription = double("subscription")
      expect(listener).to receive(:on_subscription_canceled).with(subscription, reason: "test", immediate: true)
      manager.notify(subscription, :canceled, reason: "test", immediate: true)
    end

    it "sends the subscription due for renewal event" do
      subscription = double("subscription")
      expect(listener).to receive(:on_subscription_due_for_renewal).with(subscription)
      manager.notify(subscription, :due_for_renewal)
    end

    it "sends the subscription grace period started event" do
      subscription = double("subscription")
      expect(listener).to receive(:on_subscription_grace_period_started).with(subscription, days_remaining: 5)
      manager.notify(subscription, :grace_period_started, days_remaining: 5)
    end

    it "sends the subscription grace period exceeded event" do
      subscription = double("subscription")
      expect(listener).to receive(:on_subscription_grace_period_exceeded).with(subscription)
      manager.notify(subscription, :grace_period_exceeded)
    end
  end
end
