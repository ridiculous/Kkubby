class ProductOrderController < ApplicationController
  before_action :authenticate_user

  def update
    Shelf.find(params[:shelf_id]).reorder_products(params[:products])
    head :ok
  end
end
