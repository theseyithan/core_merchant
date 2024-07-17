# frozen_string_literal: true

require_relative "core_merchant/version"
require_relative "core_merchant/customer_behavior"

# CoreMerchant module
module CoreMerchant
  class Error < StandardError; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def customer_class
      configuration.customer_class.constantize
    end
  end

  # Used to configure CoreMerchant.
  class Configuration
    attr_accessor :customer_class

    def initialize
      @customer_class = "CoreMerchant::Customer"
    end
  end

  # Default customer class in CoreMerchant. Use this class if you don't have a model for customers in your application.
  class Customer
    include CustomerBehavior

    attr_accessor :id, :email, :name

    def initialize(id:, email:, name: nil)
      @id = id
      @email = email
      @name = name
    end
  end
end
