# frozen_string_literal: true

require "rails/generators/active_record"

module CoreMerchant
  module Generators
    # Install generator for CoreMerchant
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      argument :customer_class, type: :string

      def copy_initializer
        @customer_class = customer_class.to_s.classify
        template "core_merchant.erb", "config/initializers/core_merchant.rb", customer_class: @customer_class
      end

      def copy_locales
        template "core_merchant.en.yml", "config/locales/core_merchant.en.yml"
      end

      def self.next_migration_number(_dir)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def create_migration_file
        migration_template "create_core_merchant_subscription_plans.erb",
                           "db/migrate/create_core_merchant_subscription_plans.rb"
      end

      def show_post_install
        say "CoreMerchant has been successfully installed.", :green
        say "Customer class: #{customer_class.classify}"
        say "Please run `rails db:migrate` to create the subscription plans table."
      end

      def self.banner
        "rails generate core_merchant:install --customer_class=Customer"
      end

      def self.description
        <<~DESC
          Installs CoreMerchant into your application with the specified customer class.
          This could be User, Customer, or any other existing model in your application that represents a customer."
        DESC
      end
    end
  end
end
