# CoreMerchant

> [!CAUTION]
> This gem is under development at pre-release stage

CoreMerchant is a library for customer, product, and subscription management in Rails applications. It's meant to be a starting point for building e-commerce and SaaS applications. It provides essential functionality for handling customers, products, and subscriptions. Does not include payment integrations.

## To-dos until 1.0.0 release
- [X] Add customer behavior
- [X] Add initializer generator
- [X] Add SubscriptionPlan model
- [X] Add Subscription model
- [X] Implement subscription manager and callbacks
- [X] Implement SubscriptionEvent model for logging
- [ ] Add Invoice model
- [ ] Add billing and invoicing service

## Table of contents
- [CoreMerchant](#coremerchant)
  - [To-dos until 1.0.0 release](#to-dos-until-100-release)
  - [Table of contents](#table-of-contents)
- [Installation](#installation)
- [Usage](#usage)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
    - [1. Customer class](#1-customer-class)
    - [2. Subscription listener class](#2-subscription-listener-class)
  - [Subscription management](#subscription-management)
    - [Creating a subscription plan](#creating-a-subscription-plan)
    - [Creating a subscription](#creating-a-subscription)
    - [Cancelling a subscription](#cancelling-a-subscription)
    - [Handling subscription events](#handling-subscription-events)
    - [Subscription History](#subscription-history)
  - [Public API](#public-api)
    - [SubscriptionManager](#subscriptionmanager)
    - [SubscriptionPlan](#subscriptionplan)
    - [Subscription](#subscription)
    - [SubscriptionEvent](#subscriptionevent)
      - [Subclasses](#subclasses)
        - [SubscriptionRenewalEvent](#subscriptionrenewalevent)
        - [SubscriptionStatusChangeEvent](#subscriptionstatuschangeevent)
        - [SubscriptionPlanChangeEvent](#subscriptionplanchangeevent)
        - [SubscriptionCancellationEvent](#subscriptioncancellationevent)
  - [Contributing](#contributing)


# Installation
Add this line to your application's Gemfile:
```
gem 'core_merchant', '~> 0.10.0'
```
and run `bundle install`.

Alternatively, you can install the gem manually:
```
$ gem install core_merchant
```

# Usage
The steps below will guide you through setting up CoreMerchant in your Rails application. After completing these steps, you will be able to create subscription plans, manage subscriptions, and handle subscription events.

```ruby
# Create a subscription plan
plan = CoreMerchant::SubscriptionPlan.create(name_key: 'basic', price_cents: 9_99, duration: '1m')

# Subscribe a customer to the plan
customer = current_user
subscription = CoreMerchant::Subscription.create(customer: customer, plan: plan)

# Start the subscription
CoreMerchant.subscription_manager.start_subscription(subscription)

# Use a listener to handle subscription events
class MySubscriptionListener
  include CoreMerchant::SubscriptionListener

  def on_subscription_started(subscription)
    puts "Subscription started for #{subscription.customer.email}, subscribed to #{subscription.plan.name}"
  end

  def on_subscription_due_for_renewal(subscription)
    puts "Subscription due for renewal for #{subscription.customer.email}, renewing until #{subscription.current_period_end_date}"

    # After payment is processed
    CoreMerchant.subscription_manager.payment_successful_for_renewal(subscription)
  end
end
```

## Initialization
Run the generator to create the initializer file and the migrations:
```
$ rails generate core_merchant:install
```

This will create the following files:
- `config/initializers/core_merchant.rb` - Configuration file
- `config/locales/core_merchant.en.yml` - English translations for core merchant models
- `db/migrate/xxxxxx_create_core_merchant_subscription_plans.rb` - Migration for subscription plans
- `db/migrate/xxxxxx_create_core_merchant_subscriptions.rb` - Migration for subscriptions
You can then run the migrations:
```
$ rails db:migrate
```

## Configuration
The initializer file `config/initializers/core_merchant.rb` contains the following configuration options:

### 1. Customer class
```ruby
config.customer_class = 'User'
```

This is the class that includes the `CoreMerchant::Customer` module. It should be the model class that represents your customers. For example, if you have a `User` model that represents your customers, you can include the `CoreMerchant::Customer` module in the `User` class:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  include CoreMerchant::Customer

  # ... the rest of your model code
end
```

### 2. Subscription listener class
```ruby
config.subscription_listener_class = 'MySubscriptionListener'
```
This is the class that will receive subscription events. It should include the `CoreMerchant::SubscriptionListener` module and implement event handlers for the subscription events. Some examples:
```ruby
class MySubscriptionListener
  include CoreMerchant::SubscriptionListener

  def on_test_event_received
    puts 'Test event received, hooray!'
  end
end
```

More about subscription events in the [Handling subscription events](#handling-subscription-events) section.

## Subscription management

### Creating a subscription plan
You can create a subscription plan using the `SubscriptionPlan` model:
```ruby
CoreMerchant::SubscriptionPlan.create(name_key: 'basic', price_cents: 10_00, duration: '1m')
```

### Creating a subscription
You can create a subscription for a customer using the `Subscription` model:
```ruby
customer = User.find(1)
plan = CoreMerchant::SubscriptionPlan.find_by(name_key: 'basic')
subscription = CoreMerchant::Subscription.create(customer: customer, plan: plan)
```

Note that the subscription will not be active until you start it:
```ruby
subscription.start
```

### Cancelling a subscription
You can cancel a subscription by calling the `cancel` method. You can also specify a reason for the cancellation and whether the cancellation should take effect immediately or at the end of the current billing period:
```ruby
subscription.cancel(reason: 'Customer request', at_period_end: false)
```

### Handling subscription events
You can handle subscription events by implementing event handlers in the subscription listener class. For example, you can send an email to the customer when a subscription is created:
```ruby
class MySubscriptionListener
  include CoreMerchant::SubscriptionListener

  
  def on_subscription_created(subscription)
    FakeEmailService.send_email(subscription.customer.email, "We're happy to have you on board!")

    # You can also start the subscription automatically
    subscription.start
  end

  def on_subscription_started(subscription)
    FakeEmailService.send_email(subscription.customer.email, "Your subscription has started!")
  end

  def on_subscription_due_for_renewal(subscription)
    success = FakePaymentService.charge(subscription.customer, subscription.plan.price_cents)

    if success
      CoreMerchant.subscription_manager.payment_successful_for_renewal(subscription)
    else
      FakeEmailService.send_email(subscription.customer.email, "Payment failed, please update your payment method.")
      CoreMerchant.subscription_manager.payment_failed_for_renewal(subscription)
    end
  end

  def on_subscription_renewed(subscription)
    FakeEmailService.send_email(subscription.customer.email, "Your subscription has been renewed until #{subscription.current_period_end_date}")
  end
end
```

Available subscription events:
- `on_subscription_created(subscription)`
- `on_subscription_destroyed(subscription)`
- `on_subscription_started(subscription)`
- `on_subscription_canceled(subscription, reason:, at_period_end:)`
- `on_subscription_due_for_renewal(subscription)`
- `on_subscription_renewed(subscription)`
- `on_subscription_renewal_payment_processing(subscription)`
- `on_subscription_grace_period_started(subscription, days_remaining:)`

### Subscription History
CoreMerchant now keeps a detailed history of subscription events, including creations, renewals, cancellations, status changes, and plan changes. This provides an audit trail and can be useful for debugging, customer support, and analytics.

To access a subscription's history:
```ruby
subscription = CoreMerchant::Subscription.find(42)

# Get all events
subscription.subscription_events

# Get specific event types
latest_renewal = subscription.renewal_events.last
puts "Last renewed at: #{latest_renewal.created_at}"
puts "Renewal price: #{latest_renewal.price_cents} cents, renewed until: #{latest_renewal.renewed_until}"

latest_status_change = subscription.status_change_events.last
puts "Status changed from #{latest_status_change.from} to #{latest_status_change.to}"

latest_plan_change = subscription.plan_change_events.last
puts "Plan changed from #{latest_plan_change.from_plan.name} to #{latest_plan_change.to_plan.name}"
```

## Public API
### SubscriptionManager
Access from `CoreMerchant.subscription_manager`. The `SubscriptionManager` class is responsible for managing subscriptions. It is responsible for notifying listeners when subscription events occur and checking for and handling renewals.

**Attributes**:
  - `listeners` - An array of listeners that will be notified when subscription events occur.

**Methods**:
- `check_subscriptions` - Checks all subscriptions for renewals
- `add_listener(listener)` - Adds a listener to the list of listeners
- `no_payment_needed_for_renewal(subscription)` - Handles the case where no payment is needed for a renewal.
  Call when a subscription is renewed without payment.
- `processing_payment_for_renewal(subscription)` - Handles the case where payment is being processed for a renewal.
  Call when payment is being processed for a renewal.
- `payment_successful_for_renewal(subscription)` - Handles the case where payment was successful for a renewal.
  Call when payment was successful for a renewal.
- `payment_failed_for_renewal(subscription)` - Handles the case where payment failed for a renewal.
  Call when payment failed for a renewal.

**Usage**:
```ruby
manager = CoreMerchant.subscription_manager
manager.check_subscriptions
# ... somewhere else in the code ...
manager.payment_successful_for_renewal(subscription1)
manager.payment_failed_for_renewal(subscription2)
```

### SubscriptionPlan
The `SubscriptionPlan` model represents a subscription plan in your application. Subscription plans are used to define the pricing and features of a subscription. All prices are in cents.

**Attributes**:
- `name_key`: A unique key for the subscription plan.
            This key is used to identify the plan in the application,
            as well as the translation key for the plan name through `core_merchant.subscription_plans`.
- `price_cents`: The price of the subscription plan in cents.
- `duration`: The duration of the subscription plan.
              Consists of a number and a letter representing the time unit as day, week, month, or year.
              For example, `1w` for 1 week, `3m` for 3 months, `1y` for 1 year.
- `introductory_price_cents`: The introductory price of the subscription plan in cents.
- `introductory_duration`: The duration of the introductory price of the subscription plan.

**Usage**:
``` ruby
  plan = CoreMerchant::SubscriptionPlan.new(name_key: "basic_monthly", price_cents: 7_99)
  plan.save
```
### Subscription
Represents a subscription in CoreMerchant.
This class manages the lifecycle of a customer's subscription to a specific plan.

**Subscriptions can transition through various statuses**:
- `pending`: Subscription created but not yet started
- `trial`: In a trial period
- `active`: Currently active and paid
- `past_due`: Payment failed but in grace period
- `pending_cancellation`: Will be canceled at period end
- `processing_renewal`: Renewal in progress
- `processing_payment`: Payment processing
- `canceled`: Canceled by user or due to payment failure
- `expired`: Subscription period ended
- `paused`: Temporarily halted, not yet implemented
- `pending_change`: Plan change scheduled for next renewal, not yet implemented

**Key features**:
- Supports immediate and end-of-period cancellations
- Allows plan changes, effective immediately or at next renewal
- Handles subscription pausing and resuming
- Manages trial periods
- Supports variable pricing for renewals

**Attributes**:
- `customer`: Polymorphic association to the customer
- `subscription_plan`: The current plan for this subscription
- `status`: Current status of the subscription (see enum definition)
- `start_date`: When the subscription started
- `end_date`: When the subscription ended (or will end)
- `trial_end_date`: End date of the trial period (if applicable)
- `canceled_at`: When the subscription was canceled
- `current_period_start`: Start of the current billing period
- `current_period_end`: End of the current billing period
- `pause_start_date`: When the subscription was paused
- `pause_end_date`: When the paused subscription will resume
- `current_period_price_cents`: Price for the current period
- `next_renewal_price_cents`: Price for the next renewal (if different from plan)
- `cancellation_reason`: Reason for cancellation (if applicable)

**Methods**:
- `start` - Starts the subscription
- `cancel(reason:, at_period_end:)` - Cancels the subscription, optionally at the end of the current period

**Usage**:
```ruby
subscription = CoreMerchant::Subscription.create(customer: user, subscription_plan: plan, status: :active)
subscription.start
subscription.cancel(reason: "Too expensive", at_period_end: true)
```

### SubscriptionEvent
The `SubscriptionEvent` model represents a historical log of events related to a subscription. It provides an audit trail of all significant actions and state changes for a subscription.

This class has subclasses for specific event types, such as `SubscriptionRenewalEvent`, `SubscriptionStatusChangeEvent`, and `SubscriptionPlanChangeEvent`. Each subclass has additional fields specific to the event type.

**Attributes**:
- `subscription`: Association to the related Subscription
- `event_type`: Type of the event (e.g., 'created', 'renewed', 'canceled', 'status_changed', 'plan_changed')
- `metadata`: JSON field for storing additional event-specific data

**Usage**:
```ruby
# Automatically logged when a subscription is created
subscription = CoreMerchant::Subscription.create(customer: user, subscription_plan: plan)

# Logging a custom event
subscription.log_event('custom_event', key: 'value')

# Retrieve the last renewal event
latest_renewal = subscription.renewal_events.last
puts "Last renewed at: #{latest_renewal.created_at}"
puts "Renewal price: #{latest_renewal.price_cents} cents, renewed until: #{latest_renewal.renewed_until}"

# Retrieve the last event of any type
latest_event = subscription.subscription_events.last
puts "Last event type: #{latest_event.event_type}, metadata: #{latest_event.metadata}"
```

#### Subclasses
##### SubscriptionRenewalEvent
- `price_cents`: The price of the renewal in cents
- `renewed_until`: The end date of the renewal
- `renewed_at`: The date and time of the renewal

##### SubscriptionStatusChangeEvent
- `from`: The previous status of the subscription
- `to`: The new status of the subscription

##### SubscriptionPlanChangeEvent
- `from_plan`: The previous plan of the subscription
- `to_plan`: The new plan of the subscription

##### SubscriptionCancellationEvent
- `reason`: The reason for the cancellation
- `at_period_end`: Whether the cancellation is scheduled for the end of the current period
- `canceled_at`: The date and time of the cancellation

> [!NOTE]
> Other models and features are being developed and will be added in future releases.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/theseyithan/core_merchant
