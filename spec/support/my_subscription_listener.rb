# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription_listener"

class MySubscriptionListener
  include CoreMerchant::SubscriptionListener

  def on_test_event_received
    puts "Test event received by MySubscriptionListener."
  end
end
