class PeachLily
  def initialize(debug: false)
    @catalog = Catalog.where(name: 'Peach & Lily').first_or_create!
    @visited = {}
    @url = "https://www.peachandlily.com".freeze
    @debug = debug
  end

  def call
    Mechanize.start do |agent|
      create_products(agent, type: 'Oil Cleansers')
      create_products(agent, type: 'Water Cleansers')
      create_products(agent, type: 'Toners')
      create_products(agent, type: 'Essences')
      create_products(agent, type: 'Serums / Ampoules', key: 'serum-ampoules', category: 'Serums / Ampoules')
      create_products(agent, type: 'Oils')
      create_products(agent, type: 'Moisturizers')
      create_products(agent, type: 'Eye Treatments', category: 'Eye Cream')
      create_products(agent, type: 'Sun Protection', key: 'sunscreens')
      create_products(agent, type: 'Spot Treatments')
      create_products(agent, type: 'Exfoliators')
      create_products(agent, type: 'Masks')
      create_products(agent, type: 'Kits')
    end
    true
  end

  def create_products(agent, type:, key: nil, category: key)
    cat = category && category.underscore.humanize.titlecase
    key ||= type.downcase.split.join('-')
    load_paginated_products(agent, key).each do |element|
      begin
        product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: element.document.url)
        product.image_url = element.css('.image-container img').first.attr('data-src').sub('{width}', '900')
        product.name = element.css('.product-card--title').text.strip
        product.brand = element.css('.product-card-details > span').first.text.strip.titleize.presence || type
        product.raw_price = element.css('.price').text.strip.gsub(/ /, '')
        product.product_url = "https://www.peachandlily.com#{element.css('.product-card-image a').first.attr('href')}"
        product.save || puts(product.errors.full_messages.join(', '))
      rescue => e
        if @debug
          debugger
        else
          raise e
        end
      end
    end
  end

  def load_paginated_products(agent, key)
    products = []
    page_num = 1
    loop do
      url = "https://www.peachandlily.com/collections/#{key}?page=#{page_num}"
      page = load_page(agent, url)
      # debugger if @debug
      break unless page
      items = page.css("#collection-container .product-card")
      if page_num == 1 && items.blank?
        puts "ERROR: No results found! Expected results"
      end
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
      begin
        agent.get(url)
      rescue Mechanize::ResponseCodeError => e
        puts "ERROR: #{e.class}: #{e.message}"
        puts "Skipping"
      end
    end
  end

  def test(path)
    Mechanize.new.get(@url)
  end
end
