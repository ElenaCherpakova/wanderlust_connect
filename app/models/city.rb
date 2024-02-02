class City < ApplicationRecord
  has_and_belongs_to_many :countries, join_table: 'countries_cities'
  has_many :places, dependent: :destroy
  validates :name, presence: true, length: { minimum: 3 }, format: { without: /\d/ }
  validate :unique_name_within_country

  private

  def unique_name_within_country
    if countries.any? { |country| country.cities.where.not(id: id).exists?(name: name) }
      errors.add(:name, 'A city with the same name already exists in this country.')
    end
  end
end
