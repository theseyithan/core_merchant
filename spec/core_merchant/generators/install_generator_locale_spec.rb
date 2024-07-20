# frozen_string_literal: true

require "spec_helper"
require "generators/core_merchant/install_generator"

RSpec.describe CoreMerchant::Generators::InstallGenerator, type: :generator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../tmp", __dir__)

  before do
    prepare_destination
    run_generator ["TestUser"]
  end

  after do
    FileUtils.rm_rf(destination_root)
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
