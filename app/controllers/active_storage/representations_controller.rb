# frozen_string_literal: true

# Monkey patch taken from https://github.com/rails/rails/issues/30431
# Just to support caching on the image variants
module ActiveStorage
  class RepresentationsController < BaseController
    include ActiveStorage::SetBlob

    def show
      expires_in 1.year, public: true
      variant = @blob.representation(params[:variation_key]).processed
      send_data @blob.service.download(variant.key),
                type: @blob.content_type || DEFAULT_SEND_FILE_TYPE,
                disposition: 'inline'
    end
  end
end
