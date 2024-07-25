# frozen_string_literal: true

module CoreMerchant
  module Concerns
    # This concern adds a SubscriptionEvent association including creation and retrieval
    module SubscriptionEventAssociation
      extend ActiveSupport::Concern

      EVENT_TYPES = %i[renewal status_change plan_change cancellation].freeze

      included do
        has_many :events, class_name: "SubscriptionEvent", dependent: :destroy

        EVENT_TYPES.each do |event_type|
          scope_name = "#{event_type}_events".to_sym
          class_name = "Subscription#{event_type.to_s.camelize}Event"

          has_many scope_name, -> { where(event_type: event_type) }, class_name: class_name

          define_method "create_#{event_type}_event" do |**metadata|
            events.create!(event_type: event_type, metadata: metadata)
          end
        end
      end
    end
  end
end
