# frozen_string_literal: true

require "spec_helper"
require "support/my_subscription_listener"
require "core_merchant/subscription_manager"

RSpec.describe CoreMerchant::SubscriptionListener do
  it "receives a test event" do
    expect_any_instance_of(MySubscriptionListener).to receive(:on_test_event_received)

    set_configuration
    CoreMerchant.subscription_manager.notify_test_event
  end

  private

  def set_configuration
    CoreMerchant.configure do |config|
      config.subscription_listener_class = "MySubscriptionListener"
    end
  end
end
