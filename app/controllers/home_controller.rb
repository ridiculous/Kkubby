class HomeController < ApplicationController
  before_action :authenticate_user

  def index
    @shelves = current_user.shelves.includes(:shelf_products => :product).references(:shelf_products).order('shelves.order_index').to_a
  end
end
