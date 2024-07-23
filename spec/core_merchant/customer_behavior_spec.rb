# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoreMerchant::CustomerBehavior do
  let(:customer) do
    build(:user)
  end

  it "provides a customer id" do
    expect(customer.core_merchant_customer_id).to_not be_nil
  end

  it "provides a customer email" do
    expect(customer.core_merchant_customer_email).to eq("test@example.com")
  end

  it "provides a customer name" do
    expect(customer.core_merchant_customer_name).to eq("Test User")
  end

  it "provides subscriptions" do
    customer.save

    expect(customer.subscriptions).to eq([])

    subscription = build(:subscription, customer: customer)
    subscription.save

    customer.reload
    expect(customer.subscriptions).to eq([subscription])
  end
end
