ActiveRecord::Schema.define do
  self.verbose = false

  create_table :core_merchant_subscription_plans, force: true do |t|
    t.string :name_key, null: false
    t.integer :price_cents, null: false
    t.timestamps
  end
end
