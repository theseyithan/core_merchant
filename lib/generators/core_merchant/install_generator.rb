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

      def copy_locales
        template "core_merchant.en.yml", "config/locales/core_merchant.en.yml"
      end

      def self.next_migration_number(_dir)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def create_migration_file
        migration_template "migrate/create_core_merchant_subscription_plans.erb",
                           "db/migrate/create_core_merchant_subscription_plans.rb"

        migration_template "migrate/create_core_merchant_subscriptions.erb",
                           "db/migrate/create_core_merchant_subscriptions.rb"
      end

      def show_post_install
        say "CoreMerchant has been successfully installed.", :green
        next_steps = <<~MESSAGE
          Next steps:
          1. Set the customer class in the initializer file (config/initializers/core_merchant.rb) to the class you want to use for customers.
          2. Create a subscription listener class (should include CoreMerchant::SubscriptionListener) in your app and set this class in the initializer file (config/initializers/core_merchant.rb) to the class you want to use for subscription listeners.
          3. Run `rails db:migrate` to create the subscription and subscription plan tables.
        MESSAGE
        say next_steps, :yellow
      end

      def self.banner
        "rails generate core_merchant:install"
      end

      def self.description
        <<~DESC
          Installs CoreMerchant into your application. This generator will create an initializer file, migration files for the subscription and subscription plan tables, and a locale file."
        DESC
      end
    end
  end
end
