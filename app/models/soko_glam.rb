class SokoGlam
  def call
    products = load_products
    products.map(&:save)
  end

  def load_products
    Mechanize.start do |agent|
      collect_products(agent, 'Double-Cleanse', 'oil-cleansers')
          .concat(collect_products(agent, 'Double-Cleanse', 'water-based-cleansers'))
          .concat(collect_products(agent, 'Double-Cleanse', 'makeup-remover-wipes'))
          .concat(collect_products(agent, 'Exfoliators', 'physical-exfoliators'))
          .concat(collect_products(agent, 'Exfoliators', 'chemical-exfoliators'))
          .concat(collect_products(agent, 'Toners', 'toner'))
          .concat(collect_products(agent, 'Treatments', 'essence'))
          .concat(collect_products(agent, 'Treatments', 'serum-ampoule', 'Serum / Ampoule'))
          .concat(collect_products(agent, 'Treatments', 'spot-treatment'))
          .concat(collect_products(agent, 'Masks', 'sheet-face-mask'))
          .concat(collect_products(agent, 'Masks', 'wash-off-mask'))
          .concat(collect_products(agent, 'Masks', 'sleeping-mask'))
          .concat(collect_products(agent, 'Eye Care', 'eye-cream'))
          .concat(collect_products(agent, 'Eye Care', 'eye-mask'))
          .concat(collect_products(agent, 'Moisturizers', 'mist', 'Facial Mist'))
          .concat(collect_products(agent, 'Moisturizers', 'face-moisturizer', 'Facial Moisturizer'))
          .concat(collect_products(agent, 'Moisturizers', 'face-oil', 'Facial Oil'))
          .concat(collect_products(agent, 'Sun Protection', 'sunscreen'))
          .concat(collect_products(agent, 'Sun Protection', 'spf-makeup', 'Makeup & SPF'))
          .concat(collect_products(agent, 'Hair & Beauty', 'hair-body', 'Hair & Beauty Care'))
    end
  end

  def collect_products(agent, type, key, category = key)
    url = "https://sokoglam.com/collections/#{key}"
    puts "Collecting products from ... #{url}"
    page = agent.get(url)
    page.css(".products .product-grid-item.mix").map do |element|
      product = Product.new(product_type: type, category: category.underscore.humanize.titlecase, sourced_from: page.uri.to_s)
      product.published_at = element.attr('data-published-date')
      product.image_url = element.css('.product__image a > img').first.attr('src')
      product.name = element.attr('data-name')
      product.brand = element.css('.product__vendor').first.text
      product.raw_price = element.css('.ProductPrice').first.text
      product
    end
  end
end
