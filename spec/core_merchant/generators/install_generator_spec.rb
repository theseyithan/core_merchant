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

  it "creates the initializer file" do
    assert_file "config/initializers/core_merchant.rb"
  end

  it "creates the intializer file with the default content" do
    assert_file "config/initializers/core_merchant.rb" do |config|
      expect(config).to include("CoreMerchant.configure do |config|")
      expect(config).to include("config.customer_class = TestUser")
    end
  end
end
