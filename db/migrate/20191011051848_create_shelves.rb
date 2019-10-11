class CreateShelves < ActiveRecord::Migration[6.0]
  def change
    create_table :shelves do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.integer :order_index, null: false
      t.timestamps
    end
    add_foreign_key :shelves, :users
  end
end
