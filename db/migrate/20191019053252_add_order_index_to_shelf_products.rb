class AddOrderIndexToShelfProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :shelf_products, :order_index, :integer, default: 0
  end
end
