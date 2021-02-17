# frozen_string_literal: true

json.total @articles_count
json.rows(@articles) do |article|
  json.name link_to(article.name, article)
  json.inventory_count article.inventory_count
  json.payouts_count article.payouts.count
end
