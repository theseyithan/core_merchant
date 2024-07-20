# frozen_string_literal: true

require "rails/generators/active_record"

module CoreMerchant
  module Generators
    # Install generator for CoreMerchant
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "core_merchant.rb", "config/initializers/core_merchant.rb"
      end

      def self.next_migration_number(_dir)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def create_migration_file
        migration_template "create_core_merchant_subscription_plans.erb",
                           "db/migrate/create_core_merchant_subscription_plans.rb"
      end
    end
  end
end
