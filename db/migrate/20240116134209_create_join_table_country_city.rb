class CreateJoinTableCountryCity < ActiveRecord::Migration[7.1]
  def change
    create_table :countries_cities, id: false do |t|
      t.integer :country_id, null: false
      t.integer :city_id, null: false
    end
    add_foreign_key :countries_cities, :countries
    add_foreign_key :countries_cities, :cities
  end
end
