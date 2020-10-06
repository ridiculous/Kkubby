# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task build_that_shit: :environment do
  scrapers = [
    Scrapers::SokoGlam,
    Scrapers::PeachLily,
    Scrapers::SkinCeuticals,
    Scrapers::Sephora,
  ]
  time = Benchmark.realtime do
    scrapers.map { |scraper| Thread.new { scraper.new.call } }.map(&:join)
  end
  puts "Done in #{time.round(2)}s"
end
