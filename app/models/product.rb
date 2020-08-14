class Product < ApplicationRecord
  belongs_to :catalog
  has_many :shelf_products, dependent: :destroy
  has_one_attached :image
  validates :brand, :image_url, presence: true
  validates :name, presence: true, uniqueness: { scope: :brand }
  before_create :set_price
  after_create :upload_image

  def self.types
    pluck('DISTINCT(product_type)') + pluck('DISTINCT(brand)')
  end

  def self.spellcheck(name)
    return false if name.blank?
    result = DidYouMean::SpellChecker.new(dictionary: types).correct(name).first
    if result.present?
      result unless result.casecmp?(name)
    end
  end

  def self.upload_all
    find_each &:upload_image
  end

  def upload_image
    return if image.attached?
    image.attach(filename: image_url.split('/').last.split('?').first, io: URI.open("https:#{image_url}"))
  end

  def image_for_display(size: nil)
    if image.attached?
      if size
        image.variant(resize_to_limit: size).processed
      else
        image
      end
    else
      image_url
    end
  end

  def set_price
    if raw_price
      num_price = raw_price[/\d+\.?\d*/]
      self.price = Float(num_price) if num_price
    end
  end
end
