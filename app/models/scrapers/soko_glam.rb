class Scrapers::SokoGlam
  def initialize
    @catalog = Catalog.where(name: 'Soko Glam').first_or_create!
  end

  def call
    Mechanize.start do |agent|
      create_products(agent, 'Oil Cleansers', 'oil-cleansers', 'Cleanser')
      create_products(agent, 'Water Cleansers', 'water-based-cleansers', 'Cleanser')
      create_products(agent, 'Cleansers', 'makeup-remover-wipes', 'Cleanser')
      create_products(agent, 'Exfoliators', 'physical-exfoliators')
      create_products(agent, 'Exfoliators', 'chemical-exfoliators')
      create_products(agent, 'Toners', 'toner')
      create_products(agent, 'Treatments', 'essence', 'Serums')
      create_products(agent, 'Serums', 'serum-ampoule', 'Serums')
      create_products(agent, 'Treatments', 'spot-treatment', 'Serums')
      create_products(agent, 'Masks', 'sheet-face-mask')
      create_products(agent, 'Masks', 'wash-off-mask')
      create_products(agent, 'Masks', 'sleeping-mask')
      create_products(agent, 'Eye Care', 'eye-cream', 'Cream')
      create_products(agent, 'Eye Care', 'eye-mask', 'Mask')
      create_products(agent, 'Moisturizers', 'mist', 'Facial Mist')
      create_products(agent, 'Moisturizers', 'face-moisturizer', 'Facial Moisturizer')
      create_products(agent, 'Moisturizers', 'face-oil', 'Facial Oil')
      create_products(agent, 'Sun Protection', 'sunscreen')
      create_products(agent, 'Sun Protection', 'spf-makeup', 'Makeup & SPF')
      create_products(agent, 'Hair & Beauty', 'hair-body', 'Hair & Beauty Care')
    end
  end

  def create_products(agent, type, key, category = key)
    cat = category.underscore.humanize.titlecase
    url = "https://sokoglam.com/collections/#{key}"
    puts "Collecting products from... #{url}"
    page = agent.get(url)
    page.css(".products .product-grid-item.mix").each do |element|
      product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: page.uri.to_s)
      product.published_at = element.attr('data-published-date')
      product.image_url = element.css('.product__image img.responsive-image__image').first.attr('data-src').sub('{width}', '900')
      product.name = element.attr('data-name')
      product.brand = element.css('.product__vendor').first.text
      product.raw_price = element.css('.ProductPrice').first.text
      product.product_url = "https://sokoglam.com#{element.css('.product-grid-item__link').attr('href')}"
      product.save || puts(product.errors.full_messages.join(', '))
    end
  end

  def getone(key)
    el = nil
    Mechanize.start do |agent|
      url = "https://sokoglam.com/collections/#{key}"
      puts "Collecting products from... #{url}"
      page = agent.get(url)
      el = page.css(".products .product-grid-item.mix").first
    end
    el
  end
end
