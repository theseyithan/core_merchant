# frozen_string_literal: true

require "spec_helper"
require "core_merchant/subscription_listener"

class MySubscriptionListener
  include CoreMerchant::SubscriptionListener

  def on_test_event_received; end

  def on_subscription_created(subscription); end

  def on_subscription_destroyed(subscription); end

  def on_subscription_started(subscription); end

  def on_subscription_canceled(subscription, reason:, immediate:); end
end
