class HomeController < ApplicationController
  before_action :user_from_params, only: :show

  def index
  end

  def show
    @shelves = @user.shelves.includes(:shelf_products => :product).references(:shelf_products).order('shelves.order_index').to_a
  end
end
