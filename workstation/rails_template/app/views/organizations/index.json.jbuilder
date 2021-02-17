# frozen_string_literal: true

json.total @organizations_count
json.rows(@organizations) do |organization|
  json.name link_to(organization.name, organization)
  json.logo image_tag(organization.logo, style: 'height: 3em;')
  json.products_count number_to_human(organization.products.count)
end
