# frozen_string_literal: true

require "spec_helper"
require "support/my_subscription_listener"

RSpec.describe CoreMerchant do
  it "has a version number" do
    expect(CoreMerchant::VERSION).not_to be nil
  end

  describe ".configure" do
    before do
      CoreMerchant.configuration = nil
      CoreMerchant.instance_variable_set(:@subscription_manager, nil)
    end

    it "yields the configuration" do
      expect { |b| CoreMerchant.configure(&b) }.to yield_with_args(CoreMerchant.configuration)
    end

    it "adds a subscription listener if configured" do
      CoreMerchant.configure do |config|
        config.subscription_listener_class = "MySubscriptionListener"
      end

      expect(CoreMerchant.subscription_manager.listeners).to include(an_instance_of(MySubscriptionListener))
    end

    it "does not add a subscription listener if not configured" do
      CoreMerchant.configure do |config|
      end

      expect(CoreMerchant.subscription_manager.listeners).to be_empty
    end
  end
end
