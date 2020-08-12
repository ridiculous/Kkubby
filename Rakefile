# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task build_that_shit: :environment do
  Product.sync_jobs do
    time = Benchmark.realtime do
      t = []
      t << Thread.new { SokoGlam.new.call }
      t << Thread.new { PeachLily.new.call }
      t.map(&:join)
    end
    puts "Done in #{time.round(4)}s"
  end
end
