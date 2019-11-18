class ShelvesController < ApplicationController
  before_action :authenticate_user

  def create
    shelf = current_user.shelves.new(params.require(:shelf).permit(:name))
    if shelf.save
      redirect_to home_path(anchor: shelf.name.parameterize), notice: "#{shelf.name} shelf created"
    else
      redirect_to home_path, alert: shelf.errors.full_messages.first
    end
  end

  def update
    shelf = current_user.shelves.find(params[:id])
    shelf.name_with_index = params.require(:shelf).fetch(:name_with_index)
    if shelf.name?
      if shelf.save
        redirect_to home_path(anchor: shelf.name.parameterize), notice: "Shelf name updated"
      else
        redirect_to home_path(anchor: shelf.name.parameterize), alert: shelf.errors.full_messages.first
      end
    elsif shelf.destroy
      redirect_to home_path, notice: "#{shelf.name_was} shelf was removed"
    else
      redirect_to home_path, alert: shelf.errors.full_messages.first || "Something went wrong updating shelf name"
    end
  end
end
