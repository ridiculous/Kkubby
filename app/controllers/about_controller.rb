class AboutController < ApplicationController
  def index
    @title = 'Welcome to Kkubby'
    @user = current_user
  end
end
