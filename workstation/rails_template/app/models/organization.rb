# frozen_string_literal: true

class Organization < ApplicationRecord
  include PgSearch::Model

  has_one_attached :logo
  has_many :articles
  has_many :payins
  has_many :payouts
  has_many :products
  has_many :users

  pg_search_scope :search_by_name, using: { tsearch: { prefix: true, negation: true } }, # ignoring: :accents,
                                   against: %i[name]
end
