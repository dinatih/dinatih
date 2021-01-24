require 'open-uri'
FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    logo { Rack::Test::UploadedFile.new(URI.parse(Faker::Company.unique.logo).open, 'image/png') }
    transient do
      users_count { rand(6) }
    end
    after(:create) do |organization, evaluator|
      create_list(:user, evaluator.users_count, organization: organization)
      # organization.reload
    end
  end
end
