# Created by: rails generate core_merchant:install
class CreateCoreMerchantSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :core_merchant_subscription_plans do |t|
      t.string :name_key, null: false
      t.integer :price_cents, null: false, default: 0
      t.string :duration, null: false
      t.integer :introductory_price_cents
      t.string :introductory_duration

      t.timestamps

      t.index :name_key, unique: true
    end
  end
end
