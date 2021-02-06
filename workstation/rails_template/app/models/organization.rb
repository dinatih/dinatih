# frozen_string_literal: true

class Organization < ApplicationRecord
  has_one_attached :logo
  has_many :articles
  has_many :payins
  has_many :payouts
  has_many :products
  has_many :users
end
