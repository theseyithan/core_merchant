# frozen_string_literal: true

require "bundler/setup"
Bundler.setup

require "active_record"
require "database_cleaner"
require "core_merchant"
require "rails"
require "rails/generators"
require "generator_spec"

require "factory_bot"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
load "#{File.dirname(__FILE__)}/support/schema.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    FactoryBot.find_definitions
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
