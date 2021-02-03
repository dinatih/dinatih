# frozen_string_literal: true

class Article < ApplicationRecord
  belongs_to :organization
  has_many :payments
end
