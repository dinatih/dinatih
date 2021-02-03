json.total @payments_count
json.rows(@payments) do |payment|
  json.amount link_to(number_to_currency(payment.amount), payment)
  json.succeeded_at l(payment.succeeded_at, format: :short)
  json.article link_to(payment.article.name, payment.article)
end
