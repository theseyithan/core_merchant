# frozen_string_literal: true

require "spec_helper"
require "generators/core_merchant/install_generator"

RSpec.describe CoreMerchant::Generators::InstallGenerator, type: :generator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../tmp", __dir__)

  before do
    prepare_destination
    allow(Time).to receive(:now).and_return(Time.parse("2024-01-01T00:00:00Z"))
    run_generator
  end

  it "creates the subscription plan migration file" do
    assert_migration "db/migrate/20240101000000_create_core_merchant_subscription_plans.rb" do |migration|
      assert_match(/create_table :core_merchant_subscription_plans/, migration)
    end
  end
end
