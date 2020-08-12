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
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'pids', 'sockets', 'storage')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/master.key')
# set :force_asset_precompile, true

# For single-user RVM
set :rvm_path, "/usr/share/rvm/scripts/rvm"
set :rvm_use_path, "/usr/share/rvm/scripts/rvm"

set :puma_config, -> { "#{fetch(:current_path)}/config/puma-prod.rb" }
set :pumactl_socket, -> { "#{fetch(:shared_path)}/sockets/pumactl.sock" }
set :puma_socket, -> { "#{fetch(:shared_path)}/sockets/puma.sock" }
set :puma_state, -> { "#{fetch(:shared_path)}/sockets/puma.state" }
set :puma_pid, -> { "#{fetch(:shared_path)}/pids/puma.pid" }

set :whenever_name, -> { "kkubby_production" }
set :node_version, 'stable'

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # For those using RVM, use this to load an RVM version@gemset.
  command 'source ~/.bash_profile'
  invoke :'rvm:use', '2.7.0@default'
  invoke :'nvm:load'
  command %[echo "-----> Loaded $RAILS_ENV environment"]
end

task environment: :remote_environment

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between all releases.
task :setup do
  invoke :'nvm:install'
  command %[mkdir -p "#{fetch(:shared_path)}/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/log"]
  command %[mkdir -p "#{fetch(:shared_path)}/storage"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/storage"]

  command %[mkdir -p "#{fetch(:shared_path)}/pids"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/pids"]

  command %[mkdir -p "#{fetch(:shared_path)}/sockets"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/sockets"]

  command %[mkdir -p "#{fetch(:shared_path)}/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/config"]
  command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[touch "#{fetch(:shared_path)}/config/master.key"]

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
    on :launch do
      # invoke :'whenever:update'
      invoke :'puma:phased_restart'
    end
  end
end

# namespace :whenever do
#   task :clear => :remote_environment do
#     comment "Clear contrab for #{fetch(:whenever_name)}"
#     in_path fetch(:current_path) do
#       command "#{fetch(:bundle_bin)} exec whenever --clear-crontab #{fetch(:whenever_name)} --set 'environment=#{fetch(:rails_env)}&path=#{fetch(:current_path)}'"
#     end
#   end
#
#   task :update => :remote_environment do
#     comment "Update crontab for #{fetch(:whenever_name)}"
#     in_path fetch(:current_path) do
#       command "#{fetch(:bundle_bin)} exec whenever --update-crontab #{fetch(:whenever_name)} --set 'environment=#{fetch(:rails_env)}&path=#{fetch(:current_path)}'"
#     end
#   end
#
#   task :write => :remote_environment do
#     comment "Write crontab for #{fetch(:whenever_name)}"
#     in_path fetch(:current_path) do
#       command "#{fetch(:bundle_bin)} exec whenever --write-crontab #{fetch(:whenever_name)} --set 'environment=#{fetch(:rails_env)}&path=#{fetch(:current_path)}'"
#     end
#   end
# end

namespace :nvm do
  task :load do
    command 'echo "-----> Loading nvm"'
    command %{
      source ~/.nvm/nvm.sh
    }
    command 'echo "-----> Now using nvm v.`nvm --version`"'
  end

  task :install do

    # Specifying a Node.js version
    # copy from: https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version
    #
    # Use the engines section of your package.json
    # {
    #   "name": "myapp",
    #   "description": "a really cool app",
    #   "version": "0.0.1",
    #   "engines": {
    #     "node": "0.10.x"
    #   }
    # }

    # package = File.read("package.json")
    # config = JSON.parse(package)
    # if config['engines'] && config['engines']['node']
    #   set :node_version, config['engines']['node']
    # end

    # Install Node.js via Node Version Manager
    # and symlink it to project_dir/.bin

    command %{
      echo "-----> Install node v.#{fetch(:node_version)}"
      nvm install #{fetch(:node_version)}
      ln -s ${NVM_BIN} ./.bin
    }
  end
end

task :logs do
  command %[tail -f #{fetch(:shared_path)}/log/production.log]
end

task :c => :remote_environment do
  invoke :console
end

task :stats do
  command %[free && ps aux | grep puma]
end

task status: :stats
task s: :stats

