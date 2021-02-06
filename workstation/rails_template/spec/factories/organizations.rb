# frozen_string_literal: true

require 'open-uri'
FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    logo { Rack::Test::UploadedFile.new(URI.parse(Faker::Company.logo).open, 'image/png') }

    transient do
      users_count { rand(1..8) }
      articles_count { rand(1..12) }
      payins_count { rand(1..24) }
      payouts_count { rand(1..24) }
      products_count { rand(1..12) }
    end

    after(:create) do |organization, evaluator|
      create_list(:user, evaluator.users_count, organization: organization)
      create_list(:article, evaluator.articles_count, organization: organization)
      organization.reload
      evaluator.payouts_count.times do
        articles = organization.articles
        article = articles.find(articles.ids.sample)
        users = organization.users
        user = users.find(users.ids.sample)
        create(:payout, organization: organization, article: article, user: user, succeeded_at: Date.today - rand(12))
      end

      create_list(:product, evaluator.products_count, organization: organization)
      organization.reload
      evaluator.payins_count.times do
        products = organization.products
        product = products.find(products.ids.sample)
        users = organization.users
        user = users.find(users.ids.sample)
        create(:payin, organization: organization, product: product, user: user, succeeded_at: Date.today - rand(12))
      end
    end
  end
end
