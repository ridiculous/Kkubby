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

  # @param [ShelfProduct] sp
  def product_thumbnail(sp)
    image_height = case request.env["HTTP_USER_AGENT"]
                   when /iPhone/
                     125
                   else
                     250
                   end
    css = "product-img"
    css += " wishlist" if sp.wishlist?
    css += " draggable" if can_edit?
    product_image(sp, image_height, css)
  end

  def product_enlarged(sp)
    image_height = case request.env["HTTP_USER_AGENT"]
                   when /iPhone/
                     400
                   else
                     575
                   end
    product_image(sp, image_height, 'original-product-img fl')
  end

  # @param [ShelfProduct] sp
  # @param [Integer] image_height
  # @param [String] css - classes to add to the image tag
  def product_image(sp, image_height, css = nil)
    image_tag(sp.product.image_for_display(size: [nil, image_height]), height: image_height, title: sp.name, class: css, id: sp.name.parameterize)
  end
end
