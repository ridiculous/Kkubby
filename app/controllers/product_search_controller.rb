class ProductSearchController < ApplicationController
  before_action :authenticate_user
  before_action :user_from_params

  def index
    @shelf = current_user.shelves.find(params[:shelf_id])
    @pagy, @products = pagy(load_products, items: 20)
  end

  private

  def load_products
    if params[:query].present?
      Product.where("to_tsvector(name || ' ' || brand || ' ' || product_type) @@ plainto_tsquery(?)", params[:query].strip).order(:name).includes(:image_attachment => :blob)
    else
      Product.where('1=0')
    end
  end
end
