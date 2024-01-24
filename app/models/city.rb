class City < ApplicationRecord
  has_and_belongs_to_many :countries, join_table: 'countries_cities', dependent: :destroy
  has_many :places, dependent: :destroy
  validates :name, presence: true, length: { minimum: 3 }, format: { without: /\d/ }
end
