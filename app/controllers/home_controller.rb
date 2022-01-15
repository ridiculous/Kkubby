class HomeController < ApplicationController
  before_action :user_from_params, only: :show

  def index
    if current_user
      redirect_to user_home_path(current_user)
    else
      redirect_to about_path
    end
  end

  def show
    @shelves = cache @user do
      @user.shelves.includes(:shelf_products => { :product => { :image_attachment => :blob } }).references(:shelf_products).order('shelves.order_index').to_a
    end
  end
end
