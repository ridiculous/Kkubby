class CreateCatalogs < ActiveRecord::Migration[6.0]
  def change
    create_table :catalogs do |t|
      t.string :name
      t.string :website
      t.string :image_url
      t.integer :product_count
      t.datetime :last_updated_at
      t.integer :status
      t.timestamps
    end
  end
end
