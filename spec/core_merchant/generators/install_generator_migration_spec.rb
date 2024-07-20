# frozen_string_literal: true

require "spec_helper"
require "generators/core_merchant/install_generator"

RSpec.describe CoreMerchant::Generators::InstallGenerator, type: :generator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../tmp", __dir__)

  before do
    prepare_destination
    run_generator ["--customer_class=TestUser"]
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  it "creates the subscription plan migration file" do
    assert_migration "db/migrate/create_core_merchant_subscription_plans.rb" do |migration|
      assert_match(/class CreateCoreMerchantSubscriptionPlans < ActiveRecord::Migration\[7\.1\]/, migration)
      assert_match(/create_table :core_merchant_subscription_plans/, migration)
    end
  end
end
