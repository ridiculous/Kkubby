class ProductSearchController < ApplicationController
  before_action :authenticate_user
  before_action :user_from_params

  # @todo Paginate results
  def index
    @shelf = current_user.shelves.find(params[:shelf_id])
    @products = load_products
  end

  private

  def load_products
    if params[:query].present?
      @products = Product.where("to_tsvector(name || ' ' || brand || ' ' || product_type) @@ plainto_tsquery(?)", params[:query].strip).limit(40).order(:name).to_a
    else
      []
    end
  end
end
