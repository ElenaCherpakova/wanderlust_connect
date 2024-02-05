class City < ApplicationRecord
  has_and_belongs_to_many :countries, join_table: 'countries_cities'
  has_many :places, dependent: :destroy
  validates :name, presence: true, length: { minimum: 3 }, format: { without: /\d/ }
  validate :unique_name_within_country
  before_save :capitalize_name

  private

  def capitalize_name
    self.name = name[0].capitalize.concat(name[1..]) if name.present?
  end

  def unique_name_within_country
    return unless countries.any? { |country| country.cities.where.not(id:).exists?(name:) }

    errors.add(:name, 'A city with the same name already exists in this country.')
  end
end
