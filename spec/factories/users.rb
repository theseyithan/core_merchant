# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:id) { |n| n }
    name { "Test User" }
    email { "test@example.com" }
  end
end
