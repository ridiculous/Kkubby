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
    image_height = case request.env["HTTP_USER_AGENT"]
                   when /Mobile|Android/
                     125
                   else
                     250
                   end
    css = "product-img"
    css += " wishlist" if wishlist
    css += " draggable" if draggable
    product_image(product, image_height, css)
  end

  # @param [Product] product
  def product_search_thumbnail(product)
    image_height = case request.env["HTTP_USER_AGENT"]
                   when /Mobile|Android/
                     175
                   else
                     250
                   end
    product_image(product, image_height, "product-img")
  end

  def product_enlarged(product)
    image_height = case request.env["HTTP_USER_AGENT"]
                   when /Mobile|Android/
                     275
                   else
                     500
                   end
    product_image(product, image_height, 'original-product-img fl')
  end

  # @param [Product] product
  # @param [Integer] image_height
  # @param [String] css - classes to add to the image tag
  def product_image(product, image_height, css = nil)
    image_tag(product.image_for_display(size: [image_height * 0.80, image_height, background: '#FFF']),
              height: image_height, title: product.name, class: css, id: product.name.parameterize)
  end
end
