# frozen_string_literal: true

json.total @payouts_count
json.rows(@payouts) do |payout|
  json.amount link_to(number_to_currency(payout.amount), payout)
  json.succeeded_at l(payout.succeeded_at, format: :short)
  json.article link_to(payout.article.name, payout.article)
end
