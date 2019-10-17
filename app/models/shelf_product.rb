class ShelfProduct < ApplicationRecord
  belongs_to :shelf
  belongs_to :product
end
