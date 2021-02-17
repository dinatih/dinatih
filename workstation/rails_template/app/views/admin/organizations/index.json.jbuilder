# frozen_string_literal: true

json.total @organizations_count
json.rows(@organizations) do |organization|
  json.name link_to(organization.name, organization)
  json.logo image_tag(organization.logo, style: 'height: 3em;')
  json.products_count number_to_human(organization.products.count)
  json.articles_count number_to_human(organization.articles.count)
  json.payins_count number_to_human(organization.payins.count)
  json.payouts_count number_to_human(organization.payouts.count)
  json.users_count number_to_human(organization.users.count)
end
