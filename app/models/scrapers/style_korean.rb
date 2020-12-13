class Scrapers::StyleKorean
  def initialize
    @catalog = Catalog.where(name: 'Style Korean').first_or_create!
    @domain = "https://www.stylekorean.com".freeze
  end

  def call
    Mechanize.start do |agent|
      agent.max_history = 1
      agent.log = Rails.logger if @debug
      create_products(agent,  key: 'shop/pr_listtype.php?idx=103', type: 'Cleansers', category: 'Cleanser')
      create_products(agent,  key: 'shop/pr_listtype.php?idx=66', type: 'Sheet Masks', category: 'Masks')
      create_products(agent,  key: 'shop/pr_listtype.php?idx=32', type: 'Blemish Removers', category: 'Acne')
    end
  end

  def create_products(agent, type:, key:, category:)
    url = "#{@domain}/#{key}"
    puts "Collecting products from... #{url}"
    page = agent.get(url)
    products = page.css(".recommendation_item li").map do |element|
      product = Product.new(catalog_id: @catalog.id, product_type: type, category: category, sourced_from: page.uri.to_s)
      product.published_at = Time.now
      title = element.css('.proimg').css('img').attr('alt').to_s
      brand, name = title.split(/\[(.+)\]/).reject(&:blank?).map(&:strip)
      product.name = name
      product.brand = brand
      product.raw_price = element.css('div > strike').text.strip
      product.product_url = element.css('.proimg').attr('href').to_s
      product.image_url = '[PLACEHOLDER]' # to pass validation
      product
    end
    products.select(&:valid?).each do |product|
      puts "Loading product image from... #{product.product_url}"
      product.image_url = agent.get(product.product_url).css('#sit_pvi_big').css('img').attr('src').to_s
      product.save || puts(product.errors.full_messages.join(', '))
    end
    products.size
  end
end
