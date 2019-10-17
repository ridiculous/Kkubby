class Shelf < ApplicationRecord
  belongs_to :user
  has_many :shelf_products
  has_many :products, through: :shelf_products
  validates :user_id, :name, :order_index, presence: true
  validates :name, uniqueness: { scope: :user_id }
  before_validation :default_order_index

  def self.create_defaults(user)
    user.shelves.create! name: 'Cleansers', order_index: 0
    user.shelves.create! name: 'Toners', order_index: 1
    user.shelves.create! name: 'Essences', order_index: 2
    user.shelves.create! name: 'Masks', order_index: 3
    user.shelves.create! name: 'Serum / Ampoule', order_index: 4
    user.shelves.create! name: 'Moisturizers', order_index: 5
  end

  private

  def default_order_index
    self.order_index ||= user.shelves.maximum('order_index').to_i + 1
  end
end
