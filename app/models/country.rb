class Country < ApplicationRecord
  has_and_belongs_to_many :users, join_table: 'countries_users'
  has_and_belongs_to_many :cities, join_table: 'countries_cities'
  validates :name, presence: true, length: { minimum: 3 }, format: { without: /\d/ }
end
