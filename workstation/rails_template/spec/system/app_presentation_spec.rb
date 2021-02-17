# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'App Presentation', type: :system do
  it 'Welcome to testa' do
    4.times do
      create :organization
      Faker::UniqueGenerator.clear
    end

    visit root_path
    sleep 1
    visit admin_root_path
    sleep 1
    organization = Organization.joins(:payins, :payouts).first
    visit admin_organizations_path
    sleep 3
    # visit organization_path organization
    click_on organization.name
    sleep 6
    # visit edit_organization_path organization
    click_on 'Edit'
    sleep 1
  end
end
