# frozen_string_literal: true

module CoreMerchant
  # Represents a customer in CoreMerchant.
  module CustomerBehavior
    extend ActiveSupport::Concern

    included do
    end

    def core_merchant_customer_id
      id
    end

    def core_merchant_customer_email
      email
    end

    def core_merchant_customer_name
      name if respond_to?(:name)
    end
  end
end
