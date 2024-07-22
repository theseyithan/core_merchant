# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription_plan"

RSpec.describe CoreMerchant::SubscriptionPlan do
  let(:plan) do
    build(:subscription_plan, name_key: "basic_monthly", price_cents: 9_99)
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

    it "is invalid without a duration" do
      plan.duration = nil
      expect(plan).to_not be_valid
    end

    it "is invalid with an invalid duration" do
      plan.duration = "1week"
      expect(plan).to_not be_valid

      plan.duration = "monthly"
      expect(plan).to_not be_valid
    end

    it "is invalid with an invalid introductory price cents" do
      plan.introductory_price_cents = 9.99
      expect(plan).to_not be_valid
    end

    it "is invalid with an invalid introductory duration" do
      plan.introductory_duration = "1week"
      expect(plan).to_not be_valid
    end
  end

  describe "calculated attributes" do
    it "returns the translated name" do
      plan.name_key = "example"
      allow(I18n).to receive(:t).with(
        "example", scope: "core_merchant.subscription_plans",
                   default: "Example"
      ).and_return("Super Awesome Example Plan")
      expect(plan.name).to eq("Super Awesome Example Plan")
    end

    it "returns the humanized name unless it's translated" do
      expect(plan.name).to eq("Basic monthly")
    end

    it "returns the price" do
      expect(plan.price).to eq(9.99)
    end

    it "returns the introductory price" do
      plan.introductory_price_cents = 7_99
      expect(plan.introductory_price).to eq(7.99)
    end

    it "returns the duration in date" do
      expect(plan.duration_in_date).to eq(1.month)
    end

    it "returns the introductory duration in date" do
      plan.introductory_duration = "2w"
      expect(plan.introductory_duration_in_date).to eq(2.weeks)
    end

    it "returns a string representation" do
      expect(plan.to_s).to eq("Basic monthly - 9.99")
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
