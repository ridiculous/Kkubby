class SessionsController < ApplicationController
  before_action :set_title

  def new
  end

  def create
    user = (params[:username].present? && params[:password].present?) && User.where(username: params[:username].strip.downcase).first
    if user && user.authenticate(params[:password].strip)
      sign_in_user(user)
      redirect_to(back_to || home_path, notice: "Welcome back, #{user.display_name}")
    else
      request.flash[:alert] = "Username and password don't match any records"
      render :new
    end
  end

  def destroy
    cookies.delete(:auth_token)
    reset_session
    redirect_to root_path, notice: "You're signed out"
  end

  private

  def back_to
    params[:back_to].presence
  end

  def set_title
    @title = "Kkubby - Login"
  end
end
