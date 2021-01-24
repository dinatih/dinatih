require "rails_helper"

RSpec.feature 'App Presentation' do
  scenario 'Welcome to testa' do
    4.times do
      create :organization
    end

    organization = Organization.first
    visit organizations_path
    sleep 6
    # visit organization_path organization
    click_on organization.name
    sleep 3
    # visit edit_organization_path organization
    click_on 'Edit'
    sleep 10
  end
end
