class Scrapers::Base
  attr_accessor :session

  def initialize
    @session = Capybara::Session.new(Capybara.javascript_driver, Rails.application)
  end

  def load_paginated_products(url, page: 1, key: 'currentPage', product_elements: '.css-12egk0t')
    loop do
      uri = "#{url}?#{key}=#{page}"
      puts "Loading page... #{uri}"
      session.visit(uri)
      puts "Sleeping..."
      sleep 10
      products = session.all(product_elements)
      break if products.blank?
      puts "Collecting products..."
      products.each do |element|
        session.scroll_to(element)
        sleep 1
        yield element, uri
      end
      page += 1
    end
    puts "Done!"
  end
end
