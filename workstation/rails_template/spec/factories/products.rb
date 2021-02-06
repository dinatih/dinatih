# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { Faker::Commerce.unique.product_name }
    organization { nil }
    description { Faker::TvShows::TheITCrowd.quote }
    inventory_count { rand(100) }
  end
end
