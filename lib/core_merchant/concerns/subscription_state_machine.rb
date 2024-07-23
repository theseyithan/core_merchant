# frozen_string_literal: true

require "active_support/concern"

module CoreMerchant
  module Concerns
    class InvalidTransitionError < CoreMerchant::Error; end

    # Adds state machine logic to a subscription.
    # This module defines the possible states and transitions for a subscription.
    # Possible transitions:
    # - `pending` -> `active`, `trial`, `processing_renewal`
    # - `trial` -> `processing_renewal`, `active`, `canceled`, `pending_cancellation`, `expired`
    # - `active` -> `pending_cancellation`, `canceled`, `expired`, `processing_renewal`
    # - `past_due` -> `processing_renewal`
    # - `pending_cancellation` -> `canceled`, `expired`
    # - `processing_renewal` -> `processing_payment`, `active`, `expired`, `past_due`
    # - `processing_payment` -> `active`, `expired`, `canceled`, `past_due`
    # - `canceled` -> `pending`, `processing_renewal`
    # - `expired` -> `pending`, `processing_renewal`
    module SubscriptionStateMachine
      extend ActiveSupport::Concern

      # List of possible transitions in the form of { to_state: [from_states] }
      POSSIBLE_TRANSITIONS = {
        pending: %i[canceled expired],
        trial: [:pending],
        active: %i[pending trial processing_renewal processing_payment],
        past_due: %i[active processing_renewal processing_payment],
        pending_cancellation: %i[active trial],
        processing_renewal: %i[pending trial active past_due canceled expired],
        processing_payment: [:processing_renewal],
        canceled: %i[trial active pending_cancellation processing_payment],
        expired: %i[trial active pending_cancellation processing_renewal processing_payment]
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
