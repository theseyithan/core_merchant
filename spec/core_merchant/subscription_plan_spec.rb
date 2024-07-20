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

  describe "validations" do
    it "is valid with valid attributes" do
      expect(plan).to be_valid
    end

    it "is invalid without a name key" do
      plan.name_key = nil
      expect(plan).to_not be_valid
    end

    it "is invalid with conflicting name keys" do
      plan.save
      new_plan = CoreMerchant::SubscriptionPlan.new(
        name_key: "basic.monthly",
        price_cents: 7_99
      )
      expect(new_plan).to_not be_valid
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

  describe "persistence" do
    it "can be saved" do
      expect { plan.save }.to change { CoreMerchant::SubscriptionPlan.count }.by(1)
    end

    it "can be retrieved" do
      plan.save
      expect(CoreMerchant::SubscriptionPlan.find(plan.id)).to eq(plan)
    end

    it "can be updated" do
      plan.save
      plan.update(price_cents: 7_99)
      expect(plan.reload.price_cents).to eq(7_99)
    end

    it "can be destroyed" do
      plan.save
      expect { plan.destroy }.to change { CoreMerchant::SubscriptionPlan.count }.by(-1)
    end
  end
end
