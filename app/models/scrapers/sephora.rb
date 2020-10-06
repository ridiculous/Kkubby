class Scrapers::Sephora
  def initialize(debug: false)
    @catalog = Catalog.where(name: 'Sephora').first_or_create!
    @url = "https://www.sephora.com".freeze
    @debug = debug
    @scraper = Scrapers::Base.new
  end

  def call
    @scraper.load_paginated_products("#{@url}/shop/face-serum") { |e, u| create_product(e, type: 'Serums / Ampoules', uri: u) }
  end

  def create_product(element, type:, category: type, uri: nil)
    cat = category && category.underscore.humanize.titlecase
    product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: uri)
    img = element.find('picture > img')
    link = element.find('.css-ix8km1')
    product.image_url = img[:src].split('?').first + '?imwidth=900'
    product.name = element.find('[data-at=sku_item_name]').text.strip
    product.brand = element.find('[data-at=sku_item_brand]').text.strip
    product.raw_price = element.find('[data-at=sku_item_price_list]').text.strip
    product.product_url = "#{@url}#{link[:href].to_s[/(.*)\?/, 1]}"
    product.save || puts(product.errors.full_messages.join(', '))
  rescue => e
    if @debug
      debugger
    else
      raise e
    end
  end
end
