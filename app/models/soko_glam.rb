class SokoGlam
  def initialize
    @catalog = Catalog.where(name: 'Soko Glam').first_or_create!
  end

  def call
    Mechanize.start do |agent|
      create_products(agent, 'Double-Cleanse', 'oil-cleansers')
      create_products(agent, 'Double-Cleanse', 'water-based-cleansers')
      create_products(agent, 'Double-Cleanse', 'makeup-remover-wipes')
      create_products(agent, 'Exfoliators', 'physical-exfoliators')
      create_products(agent, 'Exfoliators', 'chemical-exfoliators')
      create_products(agent, 'Toners', 'toner')
      create_products(agent, 'Treatments', 'essence')
      create_products(agent, 'Treatments', 'serum-ampoule', 'Serum / Ampoule')
      create_products(agent, 'Treatments', 'spot-treatment')
      create_products(agent, 'Masks', 'sheet-face-mask')
      create_products(agent, 'Masks', 'wash-off-mask')
      create_products(agent, 'Masks', 'sleeping-mask')
      create_products(agent, 'Eye Care', 'eye-cream')
      create_products(agent, 'Eye Care', 'eye-mask')
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
    puts "Collecting products from ... #{url}"
    page = agent.get(url)
    page.css(".products .product-grid-item.mix").each do |element|
      product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: page.uri.to_s)
      product.published_at = element.attr('data-published-date')
      product.image_url = element.css('.product__image a > img').first.attr('src')
      product.name = element.attr('data-name')
      product.brand = element.css('.product__vendor').first.text
      product.raw_price = element.css('.ProductPrice').first.text
      product.save || puts(product.errors.full_messages.join(', '))
    end
  end
end
