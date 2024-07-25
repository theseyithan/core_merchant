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
end
