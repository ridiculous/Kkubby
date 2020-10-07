class Scrapers::Ulta
  RESOURCES = {
    "skin-care-cleansers?N=2794" => { type: 'Cleansers', category: 'Cleanser' },
    "skin-care-moisturizers?N=2796" => { type: 'Moisturizers', category: 'Facial Moisturizer' },
    "skin-care-treatment-serums?N=27cs" => { type: 'Serums / Ampoules' },
    "skin-care-eye-treatments?N=270k" => { type: 'Eye Care', category: 'Cream' },
    "skin-care-suncare?N=27fe" => { type: 'Sunscreens', category: 'SPF' },
  }.freeze

  def initialize(debug: false)
    @catalog = Catalog.where(name: 'Ulta').first_or_create!
    @url = "https://www.ulta.com".freeze
    @debug = debug
  end

  def call(target_resource = nil)
    Mechanize.start do |agent|
      agent.log = Rails.logger if @debug
      RESOURCES.each do |resource, opts|
        if target_resource
          if target_resource == resource
            target_resource = nil
          else
            next
          end
        end
        load_paginated_products(agent, resource) do |element|
          create_product(element, **opts)
        end
      end
    end
  end

  def load_paginated_products(agent, resource)
    num = 0
    loop do
      # The "No" param here is really an offset, starting with 0
      url = "#{@url}/#{resource}&No=#{num * 96}&Nrpp=96"
      puts "Collecting products from... #{url}"
      page = agent.get(url)
      items = page.css("#search-prod li")
      items.each do |element|
        yield element
      end
      if items.blank?
        if num == 0
          raise "ERROR: No results found! Expected results at... #{url}"
        else
          break
        end
      end
      num += 1
    end
  end

  def create_product(element, type:, category: type)
    product = Product.new(catalog_id: @catalog.id,
                          product_type: type,
                          category: category.underscore.humanize.titlecase,
                          sourced_from: element.document.url)
    product.image_url = element.css('.product img:not(.lazyload)').first.attr('src').sub('$md$', '') + 'fmt=jpg&fit=constrain,1&hei=900&op_sharpen=1&resMode=bilin'
    product.name = element.css('.prod-desc').first.text.strip
    product.brand = element.css('.prod-title').first.text.strip
    # When there's a sale for the item, then regPrice is not there, but the original/old price is shown
    product.raw_price = (element.css('.regPrice').first || element.css('.pro-old-price').first).text.strip
    product.product_url = "#{@url}#{element.css('.prod-desc a').first.attr('href')}"
    product.save || puts(product.errors.full_messages.join(', '))
  rescue => e
    if @debug
      debugger
    else
      raise e
    end
  end
end
