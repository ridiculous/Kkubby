class PeachLily
  def initialize
    @catalog = Catalog.where(name: 'Peach & Lily').first_or_create!
  end

  def call
    Mechanize.start do |agent|
      create_products(agent, 'Double-Cleanse', 'cleansers')
    end
    true
  end

  def create_products(agent, type, key, category = key)
    cat = category.underscore.humanize.titlecase
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
    products.each do |element|
      product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: element.document.url)
      product.image_url = element.css('.imgcont a > img').first.attr('src')
      product.name = element.css('.product-title').text
      product.brand = element.css('.product-vendor').text
      product.raw_price = element.css('.price .product-price').text
      product.save || puts(product.errors.full_messages.join(', '))
    end
  end
end
