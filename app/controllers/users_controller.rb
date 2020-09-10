class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:email, :username, :password))
    if @user.save
      sign_in_user(@user)
      redirect_to user_home_path(username: @user.username), notice: 'Welcome'
    else
      error_response(@user)
      render :new
    end
  end
end
