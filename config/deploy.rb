set :application, 'suptasks'
set :repo_url, 'git@github.com:Masa331/suptasks.git'
set :deploy_to,   '/var/www/suptasks'
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets db/task_databases/databases}
set :linked_files, %w{.production suptasks.log db/user_database/user_database}
set :pty, true

namespace :deploy do
end
