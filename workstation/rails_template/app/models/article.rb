class Article < ApplicationRecord
  belongs_to :organization
  has_many :payments
end
