class PeachLily
  def initialize
    @catalog = Catalog.where(name: 'Peach & Lily').first_or_create!
    @visited = {}
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
      # Look for any stragglers we missed
      scrape_all_other_products(agent)
    end
    true
  end

  def scrape_all_other_products(agent)
    page = agent.get("https://www.peachandlily.com")
    page.css('.main-nav__list .sub-nav__link').each do |link|
      if link.attr('href').start_with?('/collections')
        create_products(agent, link.text.strip.titleize, link.attr('href').split('/').last)
      elsif link.attr('href').start_with?('/products')
        # Only a single product to scrape from the product detail page
        product_url = "https://www.peachandlily.com#{link.attr('href')}"
        page = load_page(agent, product_url)
        next unless page
        element = page.css('#productinfo')
        product = Product.new(catalog_id: @catalog.id, sourced_from: element.document.url, product_url: product_url)
        product.image_url = element.css('.main .image > img').attr('src').to_s
        product.name = element.css('#product-name').text.strip
        product.brand = element.css('#product-vendor').text.strip.titleize
        product.raw_price = element.css('#price').text.strip
        product.save || puts(product.errors.full_messages.join(', '))
      end
    end
  end

  def create_products(agent, type, key, category = key)
    cat = category && category.underscore.humanize.titlecase
    load_paginated_products(agent, key).each do |element|
      product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: element.document.url)
      product.image_url = element.css('.imgcont a > img').attr('src').to_s
      product.name = element.css('.product-title').text.strip
      product.brand = element.css('.product-vendor').text.strip.titleize
      product.raw_price = element.css('.price .product-price').text.strip
      product.product_url = "https://www.peachandlily.com#{element.css('a.image-inner-wrap').attr('href')}"
      product.save || puts(product.errors.full_messages.join(', '))
    end
  end

  def load_paginated_products(agent, key)
    products = []
    page_num = 1
    loop do
      url = "https://www.peachandlily.com/collections/#{key}?page=#{page_num}"
      page = load_page(agent, url)
      break unless page
      items = page.css(".productlist .product")
      break if items.blank?
      products.concat(items)
      page_num += 1
    end
    products
  end

  def load_page(agent, url)
    if @visited.key?(url)
      puts "Already visited #{url} ... skipping"
      false
    else
      @visited[url] = 1
      puts "Loading ... #{url}"
      agent.get(url)
    end
  end
end
