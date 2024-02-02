class Country < ApplicationRecord
  has_and_belongs_to_many :users, join_table: 'countries_users'
  has_and_belongs_to_many :cities, join_table: 'countries_cities'
  validates :name, presence: true, length: { minimum: 3 }, format: { without: /\d/ }
  validate :case_insensitive_uniqueness, on: :update
  DUPLICATE_NAME_ERROR_MESSAGE = 'has already been taken'
  after_destroy :destroy_associated_cities
  before_save :capitalize_name


  private

  def capitalize_name
    self.name = name[0].capitalize.concat(name[1..]) if name.present?
  end

  def destroy_associated_cities
    # Delete entries in the join table
    cities.each do |city|
      cities.delete(city)
    end

    # Then, delete cities if they are not associated with any other country
    City.left_outer_joins(:countries).where(countries: { id: nil }).destroy_all
  end

  def case_insensitive_uniqueness
    existing_country = Country.where("lower(name) = ?", name.downcase).where.not(id: self.id).first
    errors.add(:name, DUPLICATE_NAME_ERROR_MESSAGE) if existing_country.present?
  end
end
