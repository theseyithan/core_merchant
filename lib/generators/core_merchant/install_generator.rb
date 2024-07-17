# frozen_string_literal: true

module CoreMerchant
  module Generators
    # Install generator for CoreMerchant
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "core_merchant.rb", "config/initializers/core_merchant.rb"
      end
    end
  end
end
