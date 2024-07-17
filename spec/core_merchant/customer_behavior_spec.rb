# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoreMerchant::CustomerBehavior do
  let(:customer_class) do
    Class.new do
      include CoreMerchant::CustomerBehavior

      attr_accessor :id, :email, :name

      def initialize(id:, email:, name: nil)
        @id = id
        @email = email
        @name = name
      end
    end
  end

  let(:customer) do
    customer_class.new(id: 1, email: "test@example.com", name: "Test User")
  end

  it "provides a customer id" do
    expect(customer.core_merchant_customer_id).to eq(1)
  end

  it "provides a customer email" do
    expect(customer.core_merchant_customer_email).to eq("test@example.com")
  end

  it "provides a customer name" do
    expect(customer.core_merchant_customer_name).to eq("Test User")
  end
end
