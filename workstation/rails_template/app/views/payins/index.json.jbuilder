# frozen_string_literal: true

json.total @payins_count
json.rows(@payins) do |payin|
  json.amount link_to(number_to_currency(payin.amount), payin)
  json.succeeded_at l(payin.succeeded_at, format: :short)
  json.product link_to(payin.product.name, payin.product)
end
