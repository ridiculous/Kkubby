class HomeController < ApplicationController
  before_action :user_from_params, only: :show

  def index
    @title = 'Welcome to Kkubby'
  end

  def show
    @shelves = cache @user do
      @user.shelves.includes(:shelf_products => { :product => { :image_attachment => :blob } }).references(:shelf_products).order('shelves.order_index').to_a
    end
  end
end
