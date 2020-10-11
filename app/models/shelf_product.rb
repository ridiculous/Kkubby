class ShelfProduct < ApplicationRecord
  belongs_to :shelf, touch: true
  belongs_to :product

  delegate :name, :image_url, :image_for_display,
           to: :product
end
