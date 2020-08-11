require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/puma'

set :term_mode, :system
set :domain, 'kkubby.com'
set :user, 'root'
set :forward_agent, true
set :deploy_to, '/home/kkubby'
set :repository, 'git@github.com:ridiculous/kkubby.git'
set :branch, 'master'
set :rails, lambda { 'bin/rails' }
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'pids', 'sockets')
set :shared_files, fetch(:shared_files, []).push('config/database.yml')
# set :force_asset_precompile, true

# For single-user RVM
set :rvm_path, "/usr/share/rvm/bin/rvm"
set :rvm_use_path, "/usr/share/rvm/bin/rvm"

set :puma_config, -> { "#{fetch(:current_path)}/config/puma-prod.rb" }
set :pumactl_socket, -> { "#{fetch(:shared_path)}/sockets/pumactl.sock" }
set :puma_socket, -> { "#{fetch(:shared_path)}/sockets/puma.sock" }
set :puma_state, -> { "#{fetch(:shared_path)}/sockets/puma.state" }
set :puma_pid, -> { "#{fetch(:shared_path)}/pids/puma.pid" }

set :whenever_name, -> { "kkubby_production" }

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', '2.7.0@default'
  # command 'source ~/.bashrc'
end

task environment: :remote_environment

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between all releases.
task :setup do
  command %[mkdir -p "#{fetch(:shared_path)}/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/log"]

  command %[mkdir -p "#{fetch(:shared_path)}/pids"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/pids"]

  command %[mkdir -p "#{fetch(:shared_path)}/sockets"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/sockets"]

  command %[mkdir -p "#{fetch(:shared_path)}/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/config"]
  command %[touch "#{fetch(:shared_path)}/config/database.yml"]

  command %[echo "-----> Be sure to edit '#{fetch(:shared_path)}/config/database.yml'."]
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    # Download and prepare the app
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_create'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    # @todo fix for initial setup (currently errors)
    invoke :'send_pending'
    on :launch do
      invoke :'whenever:update'
      invoke :'puma:phased_restart'
    end
  end
end

namespace :whenever do
  task :clear => :remote_environment do
    comment "Clear contrab for #{fetch(:whenever_name)}"
    in_path fetch(:current_path) do
      command "#{fetch(:bundle_bin)} exec whenever --clear-crontab #{fetch(:whenever_name)} --set 'environment=#{fetch(:rails_env)}&path=#{fetch(:current_path)}'"
    end
  end

  task :update => :remote_environment do
    comment "Update crontab for #{fetch(:whenever_name)}"
    in_path fetch(:current_path) do
      command "#{fetch(:bundle_bin)} exec whenever --update-crontab #{fetch(:whenever_name)} --set 'environment=#{fetch(:rails_env)}&path=#{fetch(:current_path)}'"
    end
  end

  task :write => :remote_environment do
    comment "Write crontab for #{fetch(:whenever_name)}"
    in_path fetch(:current_path) do
      command "#{fetch(:bundle_bin)} exec whenever --write-crontab #{fetch(:whenever_name)} --set 'environment=#{fetch(:rails_env)}&path=#{fetch(:current_path)}'"
    end
  end
end

task :send_pending do
  command %[cd #{fetch(:current_path)} ; BUNDLE_GEMFILE=#{fetch(:bundle_gemfile)} RAILS_ENV=production bundle exec rake notifications:send_pending]
end

task :logs do
  command %[tail -f #{fetch(:shared_path)}/log/production.log]
end

task :c do
  invoke :console
end

task :stats do
  command %[free && ps aux | grep puma]
end

task status: :stats
task s: :stats

