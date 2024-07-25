# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.timestamps
  end

  create_table :core_merchant_subscription_plans, force: true do |t|
    t.string :name_key, null: false
    t.integer :price_cents, null: false
    t.string :duration, null: false
    t.integer :introductory_price_cents
    t.string :introductory_duration
    t.timestamps
  end

  create_table :core_merchant_subscriptions, force: true do |t|
    t.references :customer, polymorphic: true
    t.references :subscription_plan
    t.integer :status, default: 0, null: false
    t.datetime :start_date
    t.datetime :end_date
    t.datetime :trial_end_date
    t.datetime :canceled_at
    t.datetime :current_period_start
    t.datetime :current_period_end
    t.datetime :pause_start_date
    t.datetime :pause_end_date
    t.integer :next_renewal_price_cents
    t.string :cancellation_reason
    t.timestamps
  end

  create_table :core_merchant_subscription_events, force: true do |t|
    t.references :subscription, null: false, foreign_key: { to_table: :core_merchant_subscriptions }
    t.string :event_type, null: false
    t.string :message
    t.timestamps
  end
end
