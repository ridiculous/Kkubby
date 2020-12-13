class ShelfProductsController < ApplicationController
  before_action :user_from_params, only: :show
  before_action :authenticate_user, except: :show

  def show
    @shelf_product = shelf.shelf_products.where(product_id: params[:id]).first!
    @product = @shelf_product.product
    @catalog = Catalog.find(@product.catalog_id) if @product.catalog_id
    @title += " - #{shelf.name} - #{@product.name}"
  rescue ActiveRecord::RecordNotFound
    redirect_to home_path, alert: 'Resource not found'
  end

  def create
    shelf.products << @product = Product.find(params[:id])
    flash[:notice] = "#{@product.name} added to your #{shelf.name}"
  rescue ActiveRecord::RecordNotUnique
    render json: { alert: "Product #{@product.name} is already on your shelf" }, status: :unprocessable_entity
  end

  def update
    @shelf_product = shelf.shelf_products.where(product_id: params[:id]).first!
    @product = @shelf_product.product
    if @shelf_product.update_attributes(params.require(:shelf_product).permit(:notes, :wishlist))
      redirect_to home_path(anchor: @product.name.parameterize), notice: "#{@product.name} updated"
    else
      flash.now[:alert] = @product.errors.full_messages.first
      render :show
    end
  end

  def destroy
    @product = shelf.products.find(params[:id])
    shelf_product = shelf.shelf_products.where(product_id: params[:id]).first!
    if shelf_product.destroy
      redirect_to home_path(anchor: shelf.name.parameterize), notice: "#{@product.name} removed from #{shelf.name}"
    else
      flash.now[:alert] = "Failed to remove product from shelf"
      render :show
    end
  end

  private

  def shelf
    @shelf ||= (@user || current_user).shelves.find(params[:shelf_id])
  end
end
