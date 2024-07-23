# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription"

RSpec.describe CoreMerchant::Subscription do
  describe "notifications to SubscriptionManager" do
    let(:subscription) do
      build(:subscription)
    end

    it "sends on creation" do
      expect(CoreMerchant.subscription_manager).to receive(:notify_subscription_created).with(subscription)
      subscription.save
    end

    it "sends on destroy" do
      subscription.save
      expect(CoreMerchant.subscription_manager).to receive(:notify_subscription_destroyed).with(subscription)
      subscription.destroy
    end
  end
end
