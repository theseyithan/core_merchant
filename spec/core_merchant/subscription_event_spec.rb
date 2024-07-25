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
end
