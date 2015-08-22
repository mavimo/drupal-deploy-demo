# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'drupalapp'
set :repo_url, 'https://github.com/mavimo/drupal-deploy-demo.git'
set :repo_tree, 'drupalapp'

set :compose_version, '1.0.0-alpha10'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/drupalapp'

# Default value for :scm is :git
set :scm, :git

# Link file settings.php
set :linked_files, fetch(:linked_files, []).push('sites/default/settings.php')

# Link dirs files
set :linked_dirs, fetch(:linked_dirs, []).push('sites/default/files')

# Remove default composer install task on deploy:updated
Rake::Task['deploy:updated'].prerequisites.delete('composer:install')

# Map composer and drush commands
# NOTE: If stage have different deploy_to
# you have to copy those line for each <stage_name>.rb
# See https://github.com/capistrano/composer/issues/22
SSHKit.config.command_map[:composer] = "#{shared_path.join("composer.phar")}"
SSHKit.config.command_map[:drush] = "#{shared_path.join("vendor/bin/drush")}"

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

# Remove old drush installation task
Rake::Task["drush:install"].clear_actions

# Install drush
namespace :drush do
  desc "Install Drush"
  task :install do
    on roles(:app) do
      within shared_path do
        execute :composer, 'require drush/drush:~7.0.0'
      end
    end
  end
end

set :ssh_options, {
   keys: File.join(Dir.pwd, "..", ".vagrant", "machines", "default", "virtualbox", "private_key"),
   auth_methods: %w(publickey),
   # forward_agent: true,
 }
