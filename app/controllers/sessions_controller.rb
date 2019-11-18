class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username]).try(:authenticate, params[:password])
    if user
      sign_in_user(user)
      redirect_to(back_to || home_path, notice: "Welcome #{user.username}".strip)
    else
      request.flash[:alert] = 'Wrong username or password'
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
