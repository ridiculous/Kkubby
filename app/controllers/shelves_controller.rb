class ShelvesController < ApplicationController
  def create
    shelf = current_user.shelves.new(params.require(:shelf).permit(:name))
    if shelf.save
      redirect_to root_path, notice: "#{shelf.name} shelf created"
    else
      redirect_to root_path, alert: shelf.errors.full_messages.first
    end
  end
end
