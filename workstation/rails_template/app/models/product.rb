# frozen_string_literal: true

class Product < ApplicationRecord
  include PgSearch::Model

  belongs_to :organization
  has_many :payins

  pg_search_scope :search_by_name, using: { tsearch: { prefix: true, negation: true } }, # ignoring: :accents,
                                   against: %i[name]
end
