# frozen_string_literal: true

FactoryBot.define do
  factory :payout do
    organization { nil }
    article { nil }
    user { nil }
    amount { Faker::Commerce.price }
  end
end
