class Product < ApplicationRecord
  validates :brand, :category, :product_type, presence: true
  validates :name, presence: true, uniqueness: { scope: :brand }
  before_create :set_price

  def set_price
    if raw_price
      num_price = raw_price[/\d+\.?\d*/]
      self.price = Float(num_price) if num_price
    end
  end
end
