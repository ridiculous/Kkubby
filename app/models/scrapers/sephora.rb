class Scrapers::Sephora
  def initialize(debug: false)
    @catalog = Catalog.where(name: 'Sephora').first_or_create!
    @url = "https://www.sephora.com".freeze
    @debug = debug
    @scraper = Scrapers::Base.new
  end

  def call
    @scraper.load_paginated_products("#{@url}/shop/face-serum") do |e, u|
      create_product(e, type: 'Serums / Ampoules', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/acne-treatment-blemish-remover") do |e, u|
      create_product(e, type: 'Blemish Removers', category: 'Acne', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/night-cream") do |e, u|
      create_product(e, type: 'Night Creams', category: 'Cream', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/cleansing-oil-face-oil") do |e, u|
      create_product(e, type: 'Facial Oils', category: 'Oil', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/face-mist-face-spray") do |e, u|
      create_product(e, type: 'Facial Mists', category: 'Moisturizer', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/bb-cream-cc-cream") do |e, u|
      create_product(e, type: 'BB & CC Creams', category: 'Cream', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/face-wash-facial-cleanser") do |e, u|
      create_product(e, type: 'Cleansers', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/exfoliating-scrub-exfoliator") do |e, u|
      create_product(e, type: 'Exfoliators', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/makeup-remover-skincare") do |e, u|
      create_product(e, type: 'Makeup Removers', category: 'Makeup', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/face-wipes") do |e, u|
      create_product(e, type: 'Facial Wipes', category: 'Cleansers', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/facial-toner-skin-toner") do |e, u|
      create_product(e, type: 'Facial Toners', category: 'Toner', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/facial-treatment-masks") do |e, u|
      create_product(e, type: 'Face Masks', category: 'Mask', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/sheet-masks") do |e, u|
      create_product(e, type: 'Sheet Masks', category: 'Mask', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/eye-cream-dark-circles") do |e, u|
      create_product(e, type: 'Eye Care', category: 'Cream', uri: u)
    end
    @scraper.load_paginated_products("#{@url}/shop/eye-mask") do |e, u|
      create_product(e, type: 'Eye Care', category: 'Mask', uri: u)
    end
  end

  def create_product(element, type:, category: type, uri: nil)
    product = Product.new(catalog_id: @catalog.id,
                          product_type: type,
                          category: category.underscore.humanize.titlecase,
                          sourced_from: uri)
    product.image_url = element.find('picture > img')[:src].split('?').first + '?imwidth=900'
    product.name = element.find('[data-at=sku_item_name]').text.strip
    product.brand = element.find('[data-at=sku_item_brand]').text.strip
    product.raw_price = element.find('[data-at=sku_item_price_list]').text.strip
    product.product_url = "#{@url}#{element.find('.css-ix8km1')[:href].to_s[/(.*)\?/, 1]}"
    product.save || puts(product.errors.full_messages.join(', '))
  rescue => e
    if @debug
      debugger
    else
      raise e
    end
  end
end
