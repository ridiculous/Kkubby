class SokoGlam
  def call
    Mechanize.start do |agent|
      page = agent.get("https://sokoglam.com/collections/oil-cleansers")
      page.css(".products .product-grid-item.mix").map do |element|
        product = OpenStruct.new(category: 'oil-cleansers')
        product.published_at = element.attr('data-published-date')
        product.image_url = element.css('.product__image a > img').first.attr('src')
        product.name = element.attr('data-name')
        product.brand = element.css('.product__vendor').first.text
        product.price = element.css('.ProductPrice').first.text
        product
      end
    end
  end
end
