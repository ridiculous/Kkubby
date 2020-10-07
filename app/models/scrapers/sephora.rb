class Scrapers::Sephora
  RESOURCES = {
    "shop/face-serum" => { type: 'Serums / Ampoules' },
    "shop/acne-treatment-blemish-remover" => { type: 'Blemish Removers', category: 'Acne' },
    "shop/night-cream" => { type: 'Night Creams', category: 'Cream' },
    "shop/cleansing-oil-face-oil" => { type: 'Facial Oils', category: 'Oil' },
    "shop/face-mist-face-spray" => { type: 'Facial Mists', category: 'Moisturizer' },
    "shop/bb-cream-cc-cream" => { type: 'BB & CC Creams', category: 'Cream' },
    "shop/face-wash-facial-cleanser" => { type: 'Cleansers' },
    "shop/exfoliating-scrub-exfoliator" => { type: 'Exfoliators' },
    "shop/makeup-remover-skincare" => { type: 'Makeup Removers', category: 'Makeup' },
    "shop/face-wipes" => { type: 'Facial Wipes', category: 'Cleansers' },
    "shop/facial-toner-skin-toner" => { type: 'Facial Toners', category: 'Toner' },
    "shop/facial-treatment-masks" => { type: 'Face Masks', category: 'Mask' },
    "shop/sheet-masks" => { type: 'Sheet Masks', category: 'Mask' },
    "shop/eye-cream-dark-circles" => { type: 'Eye Care', category: 'Cream' },
    "shop/eye-mask" => { type: 'Eye Care', category: 'Mask' },
    "shop/sunscreen-sun-protection" => { type: 'Sunscreens', category: 'SPF' },
    "shop/facial-peels" => { type: 'Facial Peels', category: 'Peel' },
  }.freeze

  def initialize(debug: false)
    @catalog = Catalog.where(name: 'Sephora').first_or_create!
    @url = "https://www.sephora.com".freeze
    @scraper = Scrapers::Base.new(@url)
    @debug = debug
  end

  def call(target_resource = nil)
    RESOURCES.each do |resource, opts|
      if target_resource
        if target_resource == resource
          target_resource = nil
        else
          next
        end
      end
      @scraper.load_paginated_products(resource) do |e, u|
        create_product(e, uri: u, **opts)
      end
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
