class ShelfProductsController < ApplicationController
  def create
    @shelf = current_user.shelves.find(params[:shelf_id])
    @shelf.products << product = Product.find(params[:id])
    redirect_to root_path, notice: "#{product.name} added to your #{@shelf.name}"
  rescue ActiveRecord::RecordNotUnique
    redirect_to product_search_path(shelf_id: params[:shelf_id], query: params[:query]), alert: "Product is already on your shelf"
  end
end
