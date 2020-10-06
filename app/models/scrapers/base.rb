class Scrapers::Base
  def initialize(domain)
    @domain = domain
  end

  def load_paginated_products(resource, page: 1, key: 'currentPage', product_elements: '.css-12egk0t')
    session = Capybara::Session.new(Capybara.javascript_driver, Rails.application)
    loop do
      uri = "#{@domain}/#{resource}?#{key}=#{page}"
      puts "Collecting products from... #{uri}"
      session.visit(uri)
      puts "Sleeping..."
      sleep 10
      products = session.all(product_elements)
      break if products.blank?
      products.each_with_index do |element, i|
        if (i + 1) % 4 == 0
          session.scroll_to(element)
          sleep 1
        end
        yield element, uri
      end
      page += 1
    end
  ensure
    puts "Shutting down session..."
    session.reset!
    session.quit
    puts "Shutdown complete"
  end
end
