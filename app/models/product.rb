require 'open-uri'
class Product < ApplicationRecord
  belongs_to :catalog
  has_many :shelf_products, dependent: :destroy
  has_one_attached :image
  validates :brand, :image_url, presence: true
  validates :name, presence: true, uniqueness: { scope: :brand }
  before_create :set_price
  after_create :upload_image

  def self.sync_jobs
    before = Rails.application.config.active_job[:queue_adapter]
    Rails.application.config.active_job[:queue_adapter] = :inline
    yield
  ensure
    Rails.application.config.active_job[:queue_adapter] = before
  end

  def self.upload_all
    sync_jobs do
      find_each do |product|
        product.upload_image
      end
    end
  end

  def upload_image
    return if image.attached?
    image.attach(filename: image_url.split('/').last.split('?').first, io: URI.open("https:#{image_url}"))
  end

  def image_for_display
    if image.attached?
      image
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
