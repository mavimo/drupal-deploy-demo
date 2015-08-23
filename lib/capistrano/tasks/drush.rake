set :make_file, nil
set :make_options, '--yes'

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

  task :make do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :drush, 'make', fetch(:make_options), "#{release_path.join(fetch(:make_file))}"
      end
    end
  end
end
