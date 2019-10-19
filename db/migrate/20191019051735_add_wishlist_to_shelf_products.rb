class AddWishlistToShelfProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :shelf_products, :wishlist, :boolean
  end
end
