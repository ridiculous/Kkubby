class ShelfProductsController < ApplicationController
  def show
    @shelf = current_user.shelves.find(params[:shelf_id])
    @product = @shelf.products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def create
    @shelf = current_user.shelves.find(params[:shelf_id])
    @shelf.products << product = Product.find(params[:id])
    redirect_to root_path(anchor: product.name.parameterize), notice: "#{product.name} added to your #{@shelf.name}"
  rescue ActiveRecord::RecordNotUnique
    redirect_to product_search_path(shelf_id: params[:shelf_id], query: params[:query]), alert: "Product is already on your shelf"
  end

  def destroy
    @shelf = current_user.shelves.find(params[:shelf_id])
    @product = @shelf.products.find(params[:id])
    shelf_product = @shelf.shelf_products.where(product_id: params[:id]).first!
    if shelf_product.destroy
      redirect_to root_path(anchor: @shelf.name.parameterize), notice: "#{@product.name} removed from #{@shelf.name}"
    else
      flash.now[:alert] = "Failed to remove product from shelf"
      render :show
    end
  end
end
