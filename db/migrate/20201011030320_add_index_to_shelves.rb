class AddIndexToShelves < ActiveRecord::Migration[6.0]
  def change
    add_index :shelves, :user_id
  end
end
