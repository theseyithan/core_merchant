# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription_plan"

RSpec.describe CoreMerchant::SubscriptionPlan do
  let(:plan) do
    CoreMerchant::SubscriptionPlan.new(
      name_key: "basic.monthly",
      price_cents: 9_99
    )
  end

  it "is valid with valid attributes" do
    expect(plan).to be_valid
  end

  it "is invalid without a name key" do
    plan.name_key = nil
    expect(plan).to_not be_valid
  end

  it "is invalid without a price cents" do
    plan.price_cents = nil
    expect(plan).to_not be_valid
  end

  it "is invalid with a non-integer price cents" do
    plan.price_cents = 9.99
    expect(plan).to_not be_valid
  end
end
