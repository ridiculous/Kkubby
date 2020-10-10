# config/puma.rb
# currently have one core
workers 2

# Run GC before fork
nakayoshi_fork

# Min and Max threads per worker
threads 1, Integer(ENV['RAILS_MAX_THREADS'] || 5)

shared_dir = "/home/kkubby/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
preload_app!
prune_bundler
activate_control_app "unix://#{shared_dir}/sockets/pumactl.sock"
