class Scrapers::StyleKorean
  RESOURCES = {
    "cosmetics/skincare/moisturizer" => { type: 'Moisturizers', category: 'Moisturizer' },
    "cosmetics/skincare/moisturizer/toner" => { type: 'Toners', category: 'Moisturizer' },
    "cosmetics/skincare/sunscreen" => { type: 'Sunscreen', category: 'SPF' },
    "cosmetics/skincare/moisturizer/face-mist" => { type: 'Facial Mists', category: 'Moisturizer' },
    "cosmetics/skincare/moisturizer/cream" => { type: 'Creams', category: 'Moisturizer' },
    "cosmetics/skincare/moisturizer/eye-cream" => { type: 'Eye Creams', category: 'Moisturizer' },
    "cosmetics/skincare/cleanser/makeup-remover" => { type: 'Makeup Removers', category: 'Cleanser' },
    "cosmetics/skincare/cleanser/face-wash" => { type: 'Face Wash', category: 'Cleanser' },
    "cosmetics/skincare/moisturizer/emulsion" => { type: 'Emulsions', category: 'Moisturizer' },
    "cosmetics/skincare/moisturizer/essence-and-oil" => { type: 'Serums', category: 'Moisturizer' },
    "shop/list.php?ca_id=10107010" => { type: 'Serums', category: 'Moisturizer' },
  }.freeze

  def initialize(debug: false)
    @catalog = Catalog.where(name: 'Style Korean').first_or_create!
    @domain = "https://www.stylekorean.com".freeze
    @debug = debug
  end

  def call(target_resource = nil)
    Mechanize.start do |agent|
      agent.max_history = 1
      agent.log = Rails.logger if @debug
      RESOURCES.each do |resource, opts|
        if target_resource
          if target_resource == resource
            target_resource = nil
          else
            next
          end
        end
        load_paginated_products(agent, resource, opts)
      end
    end
  end

  def load_paginated_products(agent, resource, opts)
    num = 1
    loop do
      # The "No" param here is really an offset, starting with 0
      url = "#{@domain}/#{resource}/page-#{num}.html"
      puts "Collecting products from... #{url}"
      page = agent.get(url)
      items = page.css(".productlist_skin li")
      products = items.map do |element|
        build_product(element, **opts)
      end
      if items.blank?
        if num == 0
          raise "ERROR: No results found! Expected results at... #{url}"
        else
          break
        end
      end
      products.select(&:valid?).each do |product|
        puts "Loading product image from... #{product.product_url}"
        product.image_url = agent.get(product.product_url).css('#sit_pvi_big').css('img').attr('src').to_s
        product.save || puts(product.errors.full_messages.join(', '))
      end
      num += 1
    end
  end

  def build_product(element, type:, category: type)
    product = Product.new(catalog_id: @catalog.id,
                          product_type: type,
                          category: category.underscore.humanize.titlecase,
                          sourced_from: element.document.url)
    title = element.css('.sct_img img').attr('alt').to_s
    brand, name = title.split(/\[(.+)\]/).reject(&:blank?).map(&:strip)
    product.name = name
    product.brand = brand
    product.product_url = element.css('.sct_img').attr('href').to_s
    product.image_url = "[PLACEHOLDER]"
    product
  end
end
