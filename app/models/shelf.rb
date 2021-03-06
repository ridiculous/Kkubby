class Shelf < ApplicationRecord
  belongs_to :user, touch: true
  has_many :shelf_products, dependent: :destroy
  has_many :products, through: :shelf_products
  validates :user_id, :name, :order_index, presence: true
  validates :name, uniqueness: { scope: :user_id }
  before_validation :default_order_index

  DEFAULTS = [
    'Oil Cleansers',
    'Water Cleansers',
    'Toners',
    'Essences',
    'Masks',
    'Serums',
    'Moisturizers',
    'SPF',
  ].freeze

  def self.create_defaults(user)
    DEFAULTS.each_with_index do |name, n|
      user.shelves.create! name: name, order_index: (n + 1) * 5
    end
  end

  # Reorder based on order of given list
  def reorder_products(ids)
    products = shelf_products.index_by(&:id)
    ids.map(&:to_i).each_with_index do |id, index|
      products[id].update_column(:order_index, index)
    end
    # Clear cache
    touch
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
