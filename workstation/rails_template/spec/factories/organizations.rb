# frozen_string_literal: true

require 'open-uri'
FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    logo { Rack::Test::UploadedFile.new(URI.parse(Faker::Company.logo).open, 'image/png') }

    transient do
      users_count { rand(1..8) }
      articles_count { rand(1..12) }
      payments_count { rand(1..24) }
    end

    after(:create) do |organization, evaluator|
      create_list(:user, evaluator.users_count, organization: organization)
      create_list(:article, evaluator.articles_count, organization: organization)
      organization.reload
      evaluator.payments_count.times do
        articles = organization.articles
        article = articles.find(articles.ids.sample)
        users = organization.users
        user = users.find(users.ids.sample)
        create(:payment, organization: organization, article: article, user: user, succeeded_at: Date.today - rand(12))
      end
    end
  end
end
