FactoryBot.define do
  factory :user do
    name { Faker::TvShows::TheITCrowd.unique.character }
    email { Faker::Internet.email(name: name) }
    password { Faker::Internet.password }
    organization { nil }
  end
end
