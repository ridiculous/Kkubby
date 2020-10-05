# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task build_that_shit: :environment do
  time = Benchmark.realtime do
    threads = [SokoGlam, PeachLily, SkinCeuticals].map do |scraper|
      Thread.new { scraper.new.call }
    end
    threads.map(&:join)
  end
  puts "Done in #{time.round(4)}s"
end
