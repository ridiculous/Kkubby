class PeachLily
  def initialize
    @catalog = Catalog.where(name: 'Peach & Lily').first_or_create!
  end

  def call
    Mechanize.start do |agent|
      create_products(agent, 'Double-Cleanse', 'cleansers')
      create_products(agent, 'Toners', 'toners')
      create_products(agent, 'Treatments', 'essence-serum')
      create_products(agent, 'Treatments', 'serums-ampoules', 'Serum / Ampoule')
      create_products(agent, 'Facial Oils', 'facial-oils')
      create_products(agent, 'Eye Care', 'eye-creams', 'Eye Cream')
      create_products(agent, 'Moisturizers', 'moisturizer', 'Facial Moisturizer')
      create_products(agent, 'Moisturizers', 'facial-mists', 'Facial Mist')
      create_products(agent, 'Exfoliators', 'exfoliate', 'Exfoliators')
      create_products(agent, 'Masks', 'sleeping-masks')
      create_products(agent, 'Masks', 'masks')
      create_products(agent, 'Masks', 'sheet-masks')
      create_products(agent, 'Sun Protection', 'sunscreen')
      create_products(agent, 'Hair & Beauty', 'body-care')
    end
    true
  end

  def create_products(agent, type, key, category = key)
    cat = category.underscore.humanize.titlecase
    load_paginated_products(agent, key).each do |element|
      product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: element.document.url)
      product.image_url = element.css('.imgcont a > img').first.attr('src')
      product.name = element.css('.product-title').text
      product.brand = element.css('.product-vendor').text
      product.raw_price = element.css('.price .product-price').text
      product.product_url = "https://www.peachandlily.com#{element.css('a.image-inner-wrap').attr('href')}"
      product.save || puts(product.errors.full_messages.join(', '))
    end
  end

  def load_paginated_products(agent, key)
    products = []
    page_num = 1
    loop do
      url = "https://www.peachandlily.com/collections/#{key}?page=#{page_num}"
      puts "Collecting products from ... #{url}"
      items = agent.get(url).css(".productlist .product")
      break if items.blank?
      products.concat(items)
      page_num += 1
    end
    products
  end
end
