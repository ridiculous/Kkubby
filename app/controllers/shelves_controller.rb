class ShelvesController < ApplicationController
  def create
    shelf = current_user.shelves.new(params.require(:shelf).permit(:name))
    if shelf.save
      redirect_to root_path, notice: "#{shelf.name} shelf created"
    else
      redirect_to root_path, alert: shelf.errors.full_messages.first
    end
  end

  def update
    shelf = current_user.shelves.find(params[:id])
    shelf.name = params.require(:shelf).fetch(:name)
    if shelf.name?
      if shelf.save
        redirect_to root_path, notice: "Shelf name updated"
      else
        redirect_to root_path, alert: shelf.errors.full_messages.first
      end
    elsif shelf.destroy
      redirect_to root_path, notice: "#{shelf.name_was} shelf was removed"
    else
      redirect_to root_path, alert: shelf.errors.full_messages.first || "Something went wrong updating shelf name"
    end
  end
end
