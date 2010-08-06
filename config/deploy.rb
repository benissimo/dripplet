set :application, "dw"
set :repository,  "http://galileoalby.unfuddle.com/svn/galileoalby_drinkingwater/"

#uncommenting this per: http://groups.google.com/group/capistrano/browse_thread/thread/42e12b2110af2e29?pli=1
#to avoid "stdin: is not a tty" warnings.
default_run_options[:pty] = true

# be sure to change these
set :user, 'madeinto'
set :domain, 'dripplet.com'

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "luna.ocssolutions.com"
role :web, "luna.ocssolutions.com"
role :db,  "luna.ocssolutions.com", :primary => true
set :deploy_to, "/home/madeinto/rails_apps"

set :deploy_via, :remote_cache

set :use_sudo, false

# database.yml task
desc "Link in the production database.yml"
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end

namespace :assets do

  task :symlink, :roles => :app do
    assets.create_dirs
    run <<-CMD
      rm -rf #{release_path}/public/avatars &&
      rm -rf #{release_path}/public/photos &&
      rm -rf #{release_path}/backups &&
      ln -nfs #{shared_path}/assets/avatars #{release_path}/public/avatars &&     
      ln -nfs #{shared_path}/assets/photos #{release_path}/public/photos &&
      ln -nfs #{shared_path}/backups #{release_path}/backups
    CMD
  end
  
  task :create_dirs, :roles => :app do
      %w(avatars photos).each do |name|
        run "mkdir -p #{shared_path}/assets/#{name}"
      end
      run "mkdir -p #{shared_path}/backups"
  end
end


# Passenger
namespace :deploy do
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  # Not needed
  task :start do
  end
 
  # Not needed
  task :stop do
  end
      
end

after "deploy:update_code", :link_production_db
after "deploy:update_code", "assets:symlink"
after "deploy:restart", "deploy:cleanup"
