class Place < ApplicationRecord
  belongs_to :city
  validates :name, presence: true, uniqueness: { scope: :city_id }
  validates :category, presence: true
  validates :rating, presence: true,
                     numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comments, presence: true
  validates :city_id, presence: true
end
