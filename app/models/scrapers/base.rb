class Scrapers::Base
  attr_reader :domain

  def initialize(domain = nil)
    @domain = domain
  end

  def with_session
    session = Capybara::Session.new(Capybara.javascript_driver, Rails.application)
    yield session
  ensure
    puts "Shutting down session..."
    session.reset!
    session.quit
    puts "Shutdown complete"
  end

  # Used for sephora
  # @todo extract to sephora class
  def load_paginated_products(resource, page: 1, key: 'currentPage', product_elements: '.css-12egk0t')
    with_session do |session|
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
    end
  end

  def test(uri)
    session = Capybara::Session.new(Capybara.javascript_driver, Rails.application)
    session.visit(uri)
    session
  end
end
