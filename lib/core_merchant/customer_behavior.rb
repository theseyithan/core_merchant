# frozen_string_literal: true

module CoreMerchant
  # Represents a customer in CoreMerchant.
  module CustomerBehavior
    extend ActiveSupport::Concern

    included do
      def core_merchant_customer_id
        id
      end

      def core_merchant_customer_email
        email
      end

      def core_merchant_customer_name
        name if respond_to?(:name)
      end

      def subscriptions
        CoreMerchant::Subscription.where(customer_id: core_merchant_customer_id)
      end
    end
  end
end
