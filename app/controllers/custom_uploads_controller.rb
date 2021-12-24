class CustomUploadsController < ApplicationController
  before_action :authenticate_user
  before_action :verify_custom_uploads
  helper_method :custom_upload

  def index
    render :new
  end

  def new
  end

  def create
    if custom_upload.update(params.require(:custom_upload).permit(:name, :brand, :product_type, :image, :product_url, :catalog_id))
      flash[:notice] = %(Product "#{custom_upload.name}" added)
      if params[:shelf_id].to_i > 0
        redirect_to product_search_path(shelf_id: params[:shelf_id].to_i, query: custom_upload.name)
      else
        redirect_to home_path
      end
    else
      flash.now[:alert] = custom_upload.errors.full_messages.first
      render :new
    end
  end

  protected

  def custom_upload
    @custom_upload ||= CustomUpload.new(user: current_user, name: params[:name])
  end
end
