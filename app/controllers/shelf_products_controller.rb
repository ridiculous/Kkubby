class ShelfProductsController < ApplicationController
  before_action :load_shelf

  def show
    @shelf_product = @shelf.shelf_products.where(product_id: params[:id]).first!
    @product = @shelf_product.product
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def create
    @shelf.products << product = Product.find(params[:id])
    redirect_to root_path(anchor: product.name.parameterize), notice: "#{product.name} added to your #{@shelf.name}"
  rescue ActiveRecord::RecordNotUnique
    redirect_to product_search_path(shelf_id: params[:shelf_id], query: params[:query]), alert: "Product is already on your shelf"
  end

  def update
    @shelf_product = @shelf.shelf_products.where(product_id: params[:id]).first!
    @product = @shelf_product.product
    if @shelf_product.update_attributes(params.require(:shelf_product).permit(:notes, :wishlist))
      redirect_to root_path(anchor: @product.name.parameterize), notice: "#{@product.name} updated"
    else
      flash.now[:alert] = @product.errors.full_messages.first
      render :show
    end
  end

  def destroy
    @product = @shelf.products.find(params[:id])
    shelf_product = @shelf.shelf_products.where(product_id: params[:id]).first!
    if shelf_product.destroy
      redirect_to root_path(anchor: @shelf.name.parameterize), notice: "#{@product.name} removed from #{@shelf.name}"
    else
      flash.now[:alert] = "Failed to remove product from shelf"
      render :show
    end
  end

  private

  def load_shelf
    @shelf = current_user.shelves.find(params[:shelf_id])
  end
end
