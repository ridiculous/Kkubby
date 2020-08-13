class SessionsController < ApplicationController
  def new
  end

  def create
    user = (params[:username].present? && params[:password].present?) && User.where(username: params[:username].strip).first
    if user&.authenticate(params[:password].strip)
      sign_in_user(user)
      redirect_to(back_to || home_path, notice: "Welcome back, #{user.display_username}.")
    else
      request.flash[:alert] = "Username and password don't match any records"
      render :new
    end
  end

  def destroy
    cookies.delete(:auth_token)
    reset_session
    render :new
  end

  private

  def back_to
    params[:back_to].presence
  end
end
