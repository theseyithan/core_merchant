# CoreMerchant

> [!CAUTION]
> This gem is under development at pre-release stage

CoreMerchant is a library for customer, product, and subscription management in Rails applications. It's meant to be a starting point for building e-commerce and SaaS applications. It provides essential functionality for handling customers, products, and subscriptions. Does not include payment integrations.

## To-dos until 1.0.0 release
- [X] Add customer behavior
- [X] Add initializer generator
- [X] Add SubscriptionPlan model
- [ ] Add Subscription model
- [ ] Add subscription management service
- [ ] Add sidekiq jobs for subscription management
- [ ] Add Invoice model
- [ ] Add billing and invoicing service

## Installation
Add this line to your application's Gemfile:
```
gem 'core_merchant', '~> 0.1.0'
```
and run `bundle install`.

Alternatively, you can install the gem manually:
```
$ gem install core_merchant
```

## Usage
### Initialization
Run the generator to create the initializer file and the migrations:
```
$ rails generate core_merchant:install --customer_class=User
```
`--customer_class` option is required and should be the name of the model that represents the customer in your application. For example, if you already have a `User` model that represents the users of your application, you can use it as the customer class in CoreMerchant.

This will create the following files:
- `config/initializers/core_merchant.rb` - Configuration file
- `db/migrate/xxxxxx_create_core_merchant_subscription_plans.rb` - Migration for subscription plans

You can then run the migrations:
```
$ rails db:migrate
```

### Configuration
The initializer file `config/initializers/core_merchant.rb` contains the following configuration options:
```ruby
config.customer_class = 'User'
```

You need to include the `CoreMerchant::Customer` module in the customer class:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  include CoreMerchant::Customer

  # ... the rest of your model code
end
```

## Models
### SubscriptionPlan
The `SubscriptionPlan` model represents a subscription plan in your application. It has the following attributes:
- `name_key`: A unique key for the subscription plan.
            This key is used to identify the plan in the application,
            as well as the translation key for the plan name through `core_merchant.subscription_plans`.
- `price_cents`: The price of the subscription plan in cents.
- `duration`: The duration of the subscription plan.
              Consists of a number and a letter representing the time unit as day, week, month, or year.
              For example, `1w` for 1 week, `3m` for 3 months, `1y` for 1 year.
- `introductory_price_cents`: The introductory price of the subscription plan in cents.
- `introductory_duration`: The duration of the introductory price of the subscription plan.

> [!NOTE]
> Other models and features are being developed and will be added in future releases.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/theseyithan/core_merchant
