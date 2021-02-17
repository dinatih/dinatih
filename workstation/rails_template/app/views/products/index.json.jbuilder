# frozen_string_literal: true

json.total @products_count
json.rows(@products) do |product|
  json.name link_to(product.name, product)
  json.inventory_count product.inventory_count
  json.payins_count product.payins.count
end
