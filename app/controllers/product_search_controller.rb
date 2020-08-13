class ProductSearchController < ApplicationController
  before_action :authenticate_user

  # @todo Paginate results
  def index
    @shelf = current_user.shelves.find(params[:shelf_id])
    @products = load_products
  end

  private

  def load_products
    if params[:query].present?
      @products = Product.where('name ilike :q OR product_type ilike :q OR brand ilike :q', q: "%#{params[:query].strip}%").limit(40).order(:name).to_a
    else
      []
    end
  end
end
