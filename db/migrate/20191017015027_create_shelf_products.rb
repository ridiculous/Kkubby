class CreateShelfProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :shelf_products do |t|
      t.integer :shelf_id
      t.integer :product_id
      t.timestamps
    end
    add_foreign_key :shelf_products, :shelves
    add_foreign_key :shelf_products, :products
    add_index :shelf_products, [:shelf_id, :product_id], unique: true
  end
end
