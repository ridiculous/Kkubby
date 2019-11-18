class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :home_path

  # rescue from missing template to check if it's a legitimate error or something unrecognized, at which point we try to render html
  rescue_from ActionView::MissingTemplate do |ex|
    if ex.message =~ /:formats=>\[.*(html).*\]/
      fail ex
    else
      render template: "#{self.class.name.underscore.sub('_controller', '')}/#{action_name}", formats: [:html]
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do |_ex|
    redirect_to root_url, alert: "Oops, the request could not be verified. Please try again."
  end

  protected

  def authenticate_user
    redirect_to_login if !session || !current_user
  end

  def current_user
    @current_user ||= defined?(@current_user) ? @current_user : begin
      User.find_by!(auth_token: cookies[:auth_token]) if cookies[:auth_token]
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn(%Q(Could not find user w/ token "#{cookies[:auth_token]}"))
      nil
    end
  end

  def redirect_to_login
    if request.format.json?
      render(json: { path: login_path, alert: 'Please sign in first' }, status: :unauthorized)
    else
      redirect_to(login_path, alert: 'Please sign in first')
    end
  end

  def sign_in_user(user)
    reset_session
    user.update_attribute(:last_active_at, Time.now)
    if params[:remember_me]
      cookies.permanent[:auth_token] = user.auth_token
    else
      cookies[:auth_token] = user.auth_token
    end
  end

  def error_response(record)
    request.flash[:alert] = record.errors.full_messages.first
  end

  def user_from_params
    if params[:username].present?
      @user = User.find_by(username: params[:username])
    else
      @user = current_user
    end
    @user || redirect_to(login_path, alert: 'User not found')
  end

  def home_path(opts = {})
    user_home_path(@user || current_user, opts)
  end
end
