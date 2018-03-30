# config valid only for current version of Capistrano
lock '3.10.1'

server '192.168.100.117', port: 22, roles: [:web, :app, :db], primary: true

set :application, 'time-window'
set :repo_url, 'git@github.com:ollpu/time-window.git'

set :application,     'time-window'
set :user,            'pi'
set :puma_threads,    [1, 1]
set :puma_workers,    0


# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :keep_releases, 5

# namespace :puma do
#   desc 'Create Directories for Puma Pids and Socket'
#   task :make_dirs do
#     on roles(:app) do
#       execute "mkdir #{shared_path}/tmp/sockets -p"
#       execute "mkdir #{shared_path}/tmp/pids -p"
#     end
#   end
# 
#   before :start, :make_dirs
#   
#   Rake::Task['start'].clear
#   desc 'Start the puma server'
#   task :start do
#     on roles(:web) do
#       # execute "cd #{release_path}", :bundle, :exec, "puma -C #{fetch(:puma_conf)}"
#     end
#   end
# 
#   Rake::Task['restart'].clear
#   desc 'Restart the puma server'
#   task :restart do
#     on roles(:web) do
#       if capture("[ -S #{fetch(:puma_socket)} ] && echo '1' || echo '0'") == '1' &&
#          capture("[ -f #{fetch(:puma_pid)} ] && echo '1' || echo '0'") == '1'
#         debug "Hot-restarting puma..."
#         execute "kill -s SIGUSR2 `cat #{fetch(:puma_pid)}`"
#         debug "Doublechecking the process restart..."
#         sleep 5
#         if capture("[ -S #{fetch(:puma_socket)} ] && echo '1' || echo '0'") == '1'
#           debug "Restart success!"
#         else
#           debug "Failed! Trying to cold reboot"
#           invoke 'puma:start'
#         end
#       else
#         debug "Server not running. Starting..."
#         invoke 'puma:start'
#       end
#     end
#   end
# 
#   Rake::Task['stop'].clear
#   desc 'Stop the puma server'
#   task :stop do
#     on roles(:web) do
#       pid = if capture("[ -f #{fetch(:puma_pid)} ] && echo '1' || echo '0'") == '1'
#         capture "cat #{fetch(:puma_pid)}"
#       elsif capture("[ -f #{fetch(:puma_state)} ] && echo '1' || echo '0'") == '1'
#         capture "cat #{fetch(:puma_state)} | sed -n 2p | awk -F ' ' '{print $2}'"
#       end
#       execute "rm -f #{fetch(:puma_pid)}"
#       execute "rm -f #{fetch(:puma_socket)}"
#       execute "rm -f #{fetch(:puma_state)}"
#       execute "kill -s SIGTERM #{pid}"
#     end
#   end
#   
#   Rake::Task['status'].clear
#   desc 'Check puma server status'
#   task :status do
#     on roles(:web) do
#       if capture("[ -S #{fetch(:puma_socket)} ] && echo '1' || echo '0'") == '1' &&
#          capture("[ -f #{fetch(:puma_pid)} ] && echo '1' || echo '0'") == '1'
#         debug 'Puma server is running'
#       else
#         debug 'Puma server is down!'
#       end
#     end
#   end
# end
# 
# 
# namespace :deploy do
#   desc "Make sure local git is in sync with remote."
#   task :check_revision do
#     on roles(:app) do
#       unless `git rev-parse HEAD` == `git rev-parse origin/master`
#         puts "WARNING: HEAD is not the same as origin/master"
#         puts "Run `git push` to sync changes."
#         exit
#       end
#     end
#   end
# 
#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       invoke 'puma:restart'
#     end
#   end
# 
#   before :starting,     :check_revision
#   after  :finishing,    :compile_assets
#   after  :finishing,    :cleanup
#   after  :finishing,    :restart
# end
