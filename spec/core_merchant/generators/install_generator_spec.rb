# frozen_string_literal: true

require "spec_helper"
require "generators/core_merchant/install_generator"

RSpec.describe CoreMerchant::Generators::InstallGenerator, type: :generator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../tmp", __dir__)

  before do
    prepare_destination
    run_generator
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  it "creates the initializer file" do
    assert_file "config/initializers/core_merchant.rb"
  end

  it "creates the intializer file with the default content" do
    assert_file "config/initializers/core_merchant.rb" do |config|
      expect(config).to include("CoreMerchant.configure do |config|")
      expect(config).to include("config.customer_class = \"User\"")
      expect(config).to include("config.subscription_listener_class = \"SubscriptionListener\"")
    end
  end

  it "creates the migration file" do
    assert_migration "db/migrate/create_core_merchant_tables.rb" do |migration|
      assert_match(/class CreateCoreMerchantTables < ActiveRecord::Migration\[7\.1\]/, migration)
      assert_match(/create_table :core_merchant_subscription_plans/, migration)
      assert_match(/create_table :core_merchant_subscriptions/, migration)
      assert_match(/create_table :core_merchant_subscription_events/, migration)
    end
  end

  it "creates the locale file" do
    assert_file "config/locales/core_merchant.en.yml"
  end

  it "creates the locale file with the default content" do
    assert_file "config/locales/core_merchant.en.yml" do |config|
      expect(config).to include("en:")
      expect(config).to include("core_merchant:")
      expect(config).to include("subscription_plans:")
    end
  end
end
