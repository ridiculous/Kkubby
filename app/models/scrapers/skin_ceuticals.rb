class Scrapers::SkinCeuticals
  def initialize(debug: false)
    @catalog = Catalog.where(name: 'SkinCeuticals').first_or_create!
    @url = "https://www.skinceuticals.com".freeze
    @debug = debug
  end

  def call
    Mechanize.start do |agent|
      agent.log = Rails.logger if @debug
      create_products(agent, key: 'skin-care/category/facial-cleansers', type: 'Cleanser')
      create_products(agent, key: 'skin-care/category/antioxidants', type: 'Serums')
      create_products(agent, key: 'skin-care/serums/hyaluronic-acid-serum', type: 'Serums')
      create_products(agent, key: 'skin-care/serums/vitamin-c-serum', type: 'Serums')
      create_products(agent, key: 'skin-care/serums/exfoliating-serum', type: 'Serums')
      create_products(agent, key: 'skin-care/serums/hydrating-serum', type: 'Serums')
      create_products(agent, key: 'skin-care/serums/oil-free-serum', type: 'Serums')
      create_products(agent, key: 'skin-care/category/sunscreens', type: 'Sun Protection', category: 'Sunscreen')
      create_products(agent, key: 'skin-care/category/facial-masks', type: 'Masks')
      create_products(agent, key: 'skin-care/category/retinol-creams', type: 'Retinol Creams', category: 'Cream')
      create_products(agent, key: 'skin-care/category/facial-toners', type: 'Toners')
      create_products(agent, key: 'skin-care/category/moisturizers', type: 'Moisturizers', category: 'Facial Moisturizer')
      create_products(agent, key: 'skin-care/category/facial-exfoliators', type: 'Exfoliators')
      create_products(agent, key: 'skin-care/category/anti-aging-creams', type: 'Anti-Aging Creams', category: 'Cream')
      create_products(agent, key: 'skin-care/category/night-creams', type: 'Night Creams', category: 'Cream')
      create_products(agent, key: 'skin-care/category/acne-products', type: 'Acne Products', category: 'Acne')
      create_products(agent, key: 'skin-care/category/eye-care', type: 'Eye Care', category: 'Cream')
      create_products(agent, key: 'skin-care/category/body-care', type: 'Body Care', category: 'Cream')
    end
  end

  def create_products(agent, type:, key:, category: type)
    cat = category && category.underscore.humanize.titlecase
    load_products(agent, key).each do |element|
      begin
        product = Product.new(catalog_id: @catalog.id, product_type: type, category: cat, sourced_from: element.document.url)
        product.image_url = element.css('.product_image_wrapper img').first.attr('data-desktop-src').sub(/sw=\d+&/, '').sub(/sh=\d+/, 'sh=900')
        name = element.css('.product_details_wrapper .product_name').first
        product.name = name.text.strip
        product.brand = @catalog.name
        product.raw_price = element.css('.product_details_wrapper .product_price').first.attr('data-pricevalue')
        product.product_url = "#{@url}#{name.attr('href').sub(/\?.+\z/, '')}"
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

  def load_products(agent, key)
    url = "#{@url}/#{key}"
    puts "Collecting products from ... #{url}"
    page = agent.get(url)
    items = page.css(".search_result_items .product_tile")
    if items.blank?
      raise "No results found! Expected results on page '#{url}'"
    else
      items
    end
  end
end
