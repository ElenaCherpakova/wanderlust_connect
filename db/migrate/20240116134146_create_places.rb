class CreatePlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :places do |t|
      t.string :name
      t.string :category
      t.integer :rating
      t.text :comments
      t.references :city, null: false, foreign_key: true

      t.timestamps
    end
  end
end
