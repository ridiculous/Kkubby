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
