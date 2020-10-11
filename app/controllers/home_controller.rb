class HomeController < ApplicationController
  before_action :user_from_params, only: :show

  def index
  end

  def show
    @shelves = Rails.cache.fetch @user do
      @user.shelves.includes(:shelf_products => { :product => { :image_attachment => :blob } }).references(:shelf_products).order('shelves.order_index').to_a
    end
  end
end
