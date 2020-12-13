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
      # Have to manually join catalogs cause association was causing extra queries on save (for some unknown reason)
      Product.joins('JOIN catalogs ON catalogs.id = products.catalog_id').where("catalogs.name ilike :q OR search_tokens @@ plainto_tsquery(:q)", q: params[:query].strip).order(:name).includes(:image_attachment => :blob)
    else
      Product.where('1=0')
    end
  end
end
