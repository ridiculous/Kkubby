class HomeController < ApplicationController
  before_action :authenticate_user

  def index
    @shelves = current_user.shelves.order(:order_index).to_a
  end
end
