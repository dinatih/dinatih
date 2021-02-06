# frozen_string_literal: true

FactoryBot.define do
  factory :payin do
    organization { nil }
    product { nil }
    user { nil }
    amount { Faker::Commerce.price }
  end
end
