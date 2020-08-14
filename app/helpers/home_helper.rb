module HomeHelper
  def suggested_product(query)
    result = Product.spellcheck(query)
    if result
      content_tag(:span, "Did you mean? ") + link_to(result, product_search_path(shelf_id: @shelf.id, query: result))
    elsif query.ends_with?("s")
      content_tag(:span, "Maybe try? ") + link_to(query.singularize, product_search_path(shelf_id: @shelf.id, query: query.singularize))
    else
      content_tag(:span, "You could Google ") + link_to(query, "https://google.com/?q=#{query}", target: '_blank')
    end
  end
end
