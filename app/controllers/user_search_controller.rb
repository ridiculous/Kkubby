class UserSearchController < ApplicationController
  before_action :authenticate_user
  before_action :user_from_params

  def index
    @pagy, @users = pagy(find_users, items: 20)
  end

  private

  def find_users
    if params[:query].present?
      User.where("username ilike :q OR name ilike :q", q: "%#{params[:query].strip}%").order(:username)
    else
      User.where('1=0')
    end
  end
end
