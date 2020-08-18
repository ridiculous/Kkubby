class Shelf < ApplicationRecord
  belongs_to :user
  has_many :shelf_products, dependent: :destroy
  has_many :products, through: :shelf_products
  validates :user_id, :name, :order_index, presence: true
  validates :name, uniqueness: { scope: :user_id }
  before_validation :default_order_index

  def self.create_defaults(user)
    user.shelves.create! name: 'Cleansers', order_index: 5
    user.shelves.create! name: 'Toners', order_index: 10
    user.shelves.create! name: 'Essences', order_index: 15
    user.shelves.create! name: 'Masks', order_index: 20
    user.shelves.create! name: 'Serums / Ampoules', order_index: 25
    user.shelves.create! name: 'Moisturizers', order_index: 30
  end

  # Reorder based on order of given list
  def reorder_products(ids)
    transaction do
      products = shelf_products.index_by(&:id)
      ids.map(&:to_i).each_with_index do |id, index|
        products[id].update_column(:order_index, index)
      end
    end
  end

  def name_with_index
    "#{order_index} - #{name}"
  end

  def name_with_index=(val)
    if val.to_s.match(/\A(-?\d+)\s*-(.*)/)
      self.order_index = $1
      self.name = $2.strip
    else
      self.name = nil
    end
  end

  private

  def default_order_index
    self.order_index ||= user.shelves.maximum('order_index').to_i + 5
  end
end
