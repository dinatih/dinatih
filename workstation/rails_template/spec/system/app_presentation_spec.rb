require 'rails_helper'

RSpec.describe 'App Presentation', type: :system do
  it 'Welcome to testa' do
    4.times do
      create :organization
      Faker::UniqueGenerator.clear
    end

    visit root_path
    sleep 1
    organization = Organization.joins(:payments).first
    visit organizations_path
    sleep 3
    # visit organization_path organization
    click_on organization.name
    sleep 3
    # visit edit_organization_path organization
    click_on 'Edit'
    sleep 3
  end
end
