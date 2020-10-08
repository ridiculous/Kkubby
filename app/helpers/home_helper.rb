module HomeHelper
  def suggested_product(query)
    result = Product.spellcheck(query)
    if result
      content_tag(:span, "Did you mean? ") + link_to(result, product_search_path(shelf_id: @shelf.id, query: result), class: 'bold-link')
    elsif query.ends_with?("s")
      content_tag(:span, "Maybe try? ") + link_to(query.singularize, product_search_path(shelf_id: @shelf.id, query: query.singularize), class: 'bold-link')
    else
      content_tag(:span, "You could Google ") + link_to(query, "https://google.com/?q=#{query}", target: '_blank', class: 'bold-link')
    end
  end

  # @param [Product] product
  def product_thumbnail(product, wishlist: nil, draggable: nil)
    css = "product-img"
    css += " wishlist" if wishlist
    css += " draggable" if draggable
    product_image(product, mobile_device? ? 125 : 250, css)
  end

  # @param [Product] product
  def product_search_thumbnail(product)
    product_image(product, mobile_device? ? 175 : 250, "product-img")
  end

  def product_enlarged(product)
    product_image(product, mobile_device? ? 275 : 500, 'original-product-img fl')
  end

  def mobile_device?
    request.env["HTTP_USER_AGENT"].match? /Mobile|Android/
  end

  # @param [Product] product
  # @param [Integer] image_height
  # @param [String] css - classes to add to the image tag
  def product_image(product, image_height, css = nil)
    image_tag(product.image_for_display(size: [image_height * 0.80, image_height, background: '#FFF']),
              height: image_height, title: product.name, class: css, id: product.name.parameterize)
  end
end
