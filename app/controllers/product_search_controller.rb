class ProductSearchController < ApplicationController
  def index
    @shelf = current_user.shelves.find(params[:shelf_id])
    @products = load_products
  end

  private

  def load_products
    if params[:query].present?
      @products = Product.where('name ilike :q OR category ilike :q', q: "%#{params[:query]}%").limit(40).order(:name).to_a
    else
      []
    end
  end
end
