class CreateCustomUploads < ActiveRecord::Migration[6.1]
  def change
    create_table :custom_uploads do |t|
      t.integer :user_id, null: false
      t.integer :catalog_id, null: false
      t.string :name
      t.string :brand
      t.string :product_type
      t.string :product_url, limit: 500
      t.timestamps
    end
  end
end
