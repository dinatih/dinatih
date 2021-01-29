FactoryBot.define do
  factory :article do
    name { Faker::Commerce.unique.product_name }
    organization { nil }
    description { Faker::TvShows::TheITCrowd.quote }
    count { rand(100) }
  end
end
