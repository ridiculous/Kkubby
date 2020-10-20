class Scrapers::Target
  RESOURCES = {
    "c/facial-moisturizers-skin-care-beauty/-/N-5xtzf" => { type: 'Moisturizers', category: 'Facial Moisturizer' },
    "c/facial-cleansers-skin-care-beauty/-/N-5xtzi" => { type: 'Cleansers' },
    "c/sun-tanning-skin-care-beauty/-/N-5xtzb" => { type: 'Sunscreens', category: 'SPF' },
    "c/body-lotions-creams-bath-beauty/-/N-5xtzd" => { type: 'Creams', category: 'Cream' },
    "c/face-masks-skin-care-beauty/-/N-4uxos" => { type: 'Face Masks', category: 'Mask' },
  }.freeze

  def initialize(debug: false)
    @catalog = Catalog.where(name: 'Target').first_or_create!
    @url = "https://www.target.com".freeze
    @scraper = Scrapers::Base.new(@url)
    @debug = debug
  end

  def call(target_resource = nil)
    RESOURCES.each do |resource, opts|
      if target_resource
        if target_resource == resource
          target_resource = nil
        else
          next
        end
      end
      @scraper.with_session do |session|
        load_products(session, resource) do |e, u|
          create_product(e, uri: u, **opts)
        end
      end
    end
  end

  def load_products(session, resource)
    offset = 0
    loop do
      uri = "#{@url}/#{resource}?Nao=#{offset}&sortBy=newest"
      puts "Collecting products from... #{uri}"
      session.visit(uri)
      puts "Sleeping..."
      sleep 10
      products = session.all('li.bTvKos.h-display-flex')
      break if products.blank?
      products.each_with_index do |element, i|
        if (i + 1) % 3 == 0
          session.scroll_to(element)
          sleep 1
        end
        yield element, uri
      end
      offset += 24
    end
  end

  def create_product(element, type:, category: type, uri: nil)
    product = Product.new(catalog_id: @catalog.id,
                          product_type: type,
                          category: category.underscore.humanize.titlecase,
                          sourced_from: uri)
    name = element.find('a[data-test=product-title]')
    product.image_url = element.all("source[media='(min-width: 993px)']").first[:srcset].split('?').first + '?hei=900&qlt=90&fmt=png'
    product.brand = element.find('a[data-test=itemDetail-brand]').text.strip
    product.name = name.text.strip.sub(/\A#{product.brand}\s*/, '')
    product.raw_price = element.find('span[data-test=product-price]').text.strip
    product.product_url = name[:href].to_s.split('#').first
    product.save || puts(product.errors.full_messages.join(', '))
  rescue => e
    if @debug
      debugger
    else
      raise e
    end
  end
end
