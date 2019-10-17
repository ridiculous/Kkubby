class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.integer :catalog_id
      t.string :brand
      t.string :name
      t.string :category
      t.string :product_type
      t.string :raw_price
      t.decimal :price
      t.date :published_at
      t.datetime :last_refreshed_at
      t.string :image_size
      t.string :image_url, limit: 500
      t.string :sourced_from, limit: 500
      t.string :product_url, limit: 500
      t.timestamps
    end

    add_index :products, :catalog_id
    add_index :products, [:brand, :name], unique: true
  end
end
