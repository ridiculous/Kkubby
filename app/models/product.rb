class Product < ApplicationRecord
  # @note Commented out because Rails was querying the catalog on every save, for some unknown reason
  # @todo find out why a query was performed for catalog when saving a product
  # belongs_to :catalog
  has_many :shelf_products, dependent: :destroy
  has_one_attached :image
  before_validation :normalize_brand
  validates :brand, :catalog_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :brand }
  before_create :set_price
  after_create :upload_image
  after_commit :cache_tokens

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

  def full_name
    "#{brand} - #{name}"
  end

  def upload_image
    return if image.attached?
    # In the event of custom upload, there would be no image url
    return if image_url.blank?
    url = image_url.dup
    url = url.start_with?('http') ? url : "https:#{url}"
    name = url.split('/').last.split('?').first
    url.gsub!(/\s/, '%20')
    url.gsub!('[', '%5B')
    url.gsub!(']', '%5D')
    image.attach(filename: name, io: URI.open(url))
  end

  def stored_image(height = 500)
    image_for_display(size: [height * 0.80, height, background: '#FFF'])
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

  private

  def set_price
    if raw_price
      num_price = raw_price[/\d+\.?\d*/]
      self.price = Float(num_price) if num_price
    end
  end

  def normalize_brand
    self.brand &&= brand.upcase
  end

  def cache_tokens
    update_column :search_tokens, self.class.find_by_sql("SELECT to_tsvector(name || ' ' || brand || ' ' || product_type) AS search_tokens FROM products WHERE id = #{id} LIMIT 1").first.search_tokens
  end
end
