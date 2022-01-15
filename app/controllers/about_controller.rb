class AboutController < ApplicationController
  def index
    @title = "About Kkubby"
    @user = current_user
  end
end
