class Product < ApplicationRecord
  # @note Commented out because Rails was querying the catalog on every save, for some unknown reason
  # @todo find out why a query was performed for catalog when saving a product
  # belongs_to :catalog
  has_many :shelf_products, dependent: :destroy
  has_one_attached :image
  before_validation :normalize_brand
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
    url = image_url.start_with?('http') ? image_url : "https:#{image_url}"
    image.attach(filename: image_url.split('/').last.split('?').first, io: URI.open(url.gsub(/\s/, '%20')))
  end

  def image_for_display(size: nil)
    if image.attached?
      if size
        image.variant(resize_and_pad: size).processed
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

  def normalize_brand
    self.brand &&= brand.upcase
  end
end
