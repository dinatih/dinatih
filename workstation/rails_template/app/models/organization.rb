# frozen_string_literal: true

class Organization < ApplicationRecord
  has_one_attached :logo
  has_many :articles
  has_many :payments
  has_many :users
end
