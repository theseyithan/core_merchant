# frozen_string_literal: true

module CoreMerchant
  # Represents a customer in CoreMerchant.
  module CustomerBehavior
    extend ActiveSupport::Concern

    included do
      has_many :subscriptions, class_name: "CoreMerchant::Subscription", as: :customer, dependent: :destroy

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
end
