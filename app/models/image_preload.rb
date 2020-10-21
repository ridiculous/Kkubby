class ImagePreload
  module HelperExt
    def request(*) OpenStruct.new(env: { 'HTTP_USER_AGENT' => ($USER_AGENT || 'Mobile') }) end
    def image_tag(*) :ok end
  end
  include ApplicationHelper
  include HomeHelper
  include HelperExt

  def call(product)
    Rails.logger.debug "*** Preloading image variants"
    %w[Mobile Desktop].each do |user_agent|
      $USER_AGENT = user_agent
      product_thumbnail(product)
      product_search_thumbnail(product)
      product_enlarged(product)
    end
  end
end