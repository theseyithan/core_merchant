# frozen_string_literal: true

require "active_support/concern"

module CoreMerchant
  module Concerns
    class InvalidTransitionError < CoreMerchant::Error; end

    # Adds state machine logic to a subscription.
    # This module defines the possible states and transitions for a subscription.
    # Possible transitions:
    # - `pending` -> `active`, `trial`
    # - `trial` -> `active`, `pending_cancellation`, `canceled`
    # - `active` -> `pending_cancellation`, `canceled`, `expired`
    # - `pending_cancellation` -> `canceled`, `expired`
    # - `canceled` -> `pending`, `active`
    # - `expired` -> `pending`, `active`
    module SubscriptionStateMachine
      extend ActiveSupport::Concern

      # List of possible transitions in the form of { to_state: [from_states] }
      POSSIBLE_TRANSITIONS = {
        pending: %i[canceled expired],
        trial: %i[pending],
        active: %i[pending trial canceled expired],
        pending_cancellation: %i[active trial],
        canceled: %i[active pending_cancellation trial],
        expired: %i[active pending_cancellation canceled trial],
        past_due: [],
        paused: [],
        pending_change: []
      }.freeze

      included do
        POSSIBLE_TRANSITIONS.each do |to_state, from_states|
          define_method("can_transition_to_#{to_state}?") do
            from_states.include?(status.to_sym)
          end

          define_method("transition_to_#{to_state}") do
            return false unless send("can_transition_to_#{to_state}?")

            update(status: to_state)
          end

          define_method("transition_to_#{to_state}!") do
            raise InvalidTransitionError unless send("transition_to_#{to_state}")

            update!(status: to_state)
          end
        end
      end
    end
  end
end
