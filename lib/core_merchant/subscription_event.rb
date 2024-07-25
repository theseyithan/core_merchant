# frozen_string_literal: true

module CoreMerchant
  #   The `SubscriptionEvent` model represents a historical log of events related to a subscription.
  #   It provides an audit trail of all significant actions and state changes for a subscription.

  # This class has subclasses for specific event types, such as
  # `SubscriptionRenewalEvent`, `SubscriptionStatusChangeEvent`, and `SubscriptionPlanChangeEvent`.
  # Each subclass has additional fields specific to the event type.

  # **Attributes**:
  # - `subscription`: Association to the related Subscription
  # - `event_type`: Type of the event (e.g., 'created', 'renewed', 'canceled', 'status_changed', 'plan_changed')
  # - `metadata`: JSON field for storing additional event-specific data

  # **Usage**:
  # ```ruby
  # # Automatically logged when a subscription is created
  # subscription = CoreMerchant::Subscription.create(customer: user, subscription_plan: plan)

  # # Logging a custom event
  # subscription.log_event('custom_event', key: 'value')

  # # Retrieve the last renewal event
  # latest_renewal = subscription.renewal_events.last
  # puts "Last renewed at: #{latest_renewal.created_at}"
  # puts "Renewal price: #{latest_renewal.price_cents} cents, renewed until: #{latest_renewal.renewed_until}"

  # # Retrieve the last event of any type
  # latest_event = subscription.subscription_events.last
  # puts "Last event type: #{latest_event.event_type}, metadata: #{latest_event.metadata}"
  # ```
  class SubscriptionEvent < ActiveRecord::Base
    self.table_name = "core_merchant_subscription_events"

    belongs_to :subscription, class_name: "CoreMerchant::Subscription"

    validates :event_type, presence: true

    def metadata
      value = self[:metadata]
      value.is_a?(Hash) ? value : JSON.parse(value || "{}")
    end

    def metadata=(value)
      self[:metadata] = value.is_a?(Hash) ? value.to_json : value
    end
  end

  # Represents a renewal event for a subscription.
  class SubscriptionRenewalEvent < SubscriptionEvent
    def price_cents
      metadata["price_cents"]
    end

    def price_cents=(value)
      self.metadata = metadata.merge(price_cents: value)
    end

    def renewed_from
      metadata["renewed_from"].to_date
    end

    def renewed_from=(value)
      self.metadata = metadata.merge(renewed_from: value)
    end

    def renewed_until
      metadata["renewed_until"].to_date
    end

    def renewed_until=(value)
      self.metadata = metadata.merge(renewed_until: value)
    end
  end

  # Represents a status change event for a subscription.
  class SubscriptionStatusChangeEvent < SubscriptionEvent
    def from
      metadata["from_status"]
    end

    def from=(value)
      self.metadata = metadata.merge(from_status: value)
    end

    def to
      metadata["to_status"]
    end

    def to=(value)
      self.metadata = metadata.merge(to_status: value)
    end
  end

  # Represents a plan change event for a subscription.
  class SubscriptionPlanChangeEvent < SubscriptionEvent
    def from_plan
      id = metadata["from_plan_id"]
      CoreMerchant::SubscriptionPlan.find(id) if id
    end

    def from_plan=(value)
      self.metadata = metadata.merge(from_plan_id: value.id)
    end

    def to_plan
      id = metadata["to_plan_id"]
      CoreMerchant::SubscriptionPlan.find(id) if id
    end

    def to_plan=(value)
      self.metadata = metadata.merge(to_plan_id: value.id)
    end
  end

  # Represents a cancellation event for a subscription.
  class SubscriptionCancellationEvent < SubscriptionEvent
    def canceled_at
      created_at
    end

    def at_period_end?
      metadata["at_period_end"]
    end

    def at_period_end=(value)
      self.metadata = metadata.merge(at_period_end: value)
    end

    def reason
      metadata["reason"]
    end

    def reason=(value)
      self.metadata = metadata.merge(reason: value)
    end
  end
end
