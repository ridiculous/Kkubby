# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task build_that_shit: :environment do
  scrapers = [
    Scrapers::SokoGlam,
    Scrapers::PeachLily,
    Scrapers::SkinCeuticals,
    Scrapers::Ulta,
    Scrapers::Sephora
  ]
  while scraper = scrapers.pop
    scraper.new.call
  end
  puts :Done
end

task eager_load_image_variants: :environment do
  module HelperExt
    def request(*) OpenStruct.new(env: { 'HTTP_USER_AGENT' => ($USER_AGENT || 'Mobile') }) end
    def image_tag(*) :ok end
  end
  include ApplicationHelper
  include HomeHelper
  include HelperExt
  Product.find_each do |product|
    %w[Mobile Desktop].each do |user_agent|
      $USER_AGENT = user_agent
      product_thumbnail(product)
      product_search_thumbnail(product)
      product_enlarged(product)
    end
  end
end
