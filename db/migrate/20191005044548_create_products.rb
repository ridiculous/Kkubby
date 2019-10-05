class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :brand
      t.string :image_url
      t.string :category
      t.decimal :price
      t.date :published_at
      t.datetime :last_refreshed_at
      t.string :sourced_from
      t.timestamps
    end
  end
end
