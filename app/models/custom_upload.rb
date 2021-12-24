class CustomUpload < ApplicationRecord
  belongs_to :user
  attr_accessor :image
  validates :name, :brand, :product_type, :image, :catalog_id,
    presence: true
  after_save :create_product

  def create_product
    product = Product.new attributes.slice("catalog_id", "name", "brand", "product_type", "product_url")
    if product.save
      product.image.attach(image)
    else
      errors.add(:product, product.errors.full_messages.first)
      product.save!
    end
  end
end
