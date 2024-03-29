module ApplicationHelper
  include Pagy::Frontend

  def can_edit?
    current_user && (@user.nil? || current_user.id == @user.id)
  end
end
