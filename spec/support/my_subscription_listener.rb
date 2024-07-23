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

  def on_subscription_due_for_renewal(subscription); end

  def on_subscription_renewed(subscription); end

  def on_subscription_renewal_payment_processing(subscription); end

  def on_subscription_grace_period_started(subscription, days_remaining:); end

  def on_subscription_expired(subscription); end
end
