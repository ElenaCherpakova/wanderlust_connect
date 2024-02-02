class CreateJoinTableCountryUser < ActiveRecord::Migration[7.1]
  def change
    create_table :countries_users, id: false do |t|
      t.integer :country_id, null: false
      t.integer :user_id, null: false
    end
    
    add_foreign_key :countries_users, :countries
    add_foreign_key :countries_users, :users
  end
end
