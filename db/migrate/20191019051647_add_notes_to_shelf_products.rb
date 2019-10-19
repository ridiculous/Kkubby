class AddNotesToShelfProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :shelf_products, :notes, :text
  end
end
