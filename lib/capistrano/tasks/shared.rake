# NOTICE: If you update this code, please also update the corresponding file in
# the ihat or tahi repository. These tasks are used by both, but it wasn't worth
# creating a shared repo.

namespace :deploy do
  desc 'Load the database schema'
  task schema_load: [:set_rails_env] do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:schema:load'
        end
      end
    end
  end

  desc 'First deploy: loads database schema'
  task :cold do
    before 'deploy:updated', 'deploy:schema_load'
    invoke 'deploy'
  end

  desc 'Copy ember-built assets to public/client'
  task :copy_ember_assets do
    on release_roles(fetch(:assets_roles)) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rsync, '-a', 'tmp/ember-cli/apps/client/', 'public/client/'
        end
      end
    end
  end
end

# Use service scripts to restart puma/sidekiq
[{ namespace: :puma,
   role: :app,
   service: :web_service_name },
 { namespace: :sidekiq,
   role: :worker,
   service: :worker_service_name },
 { namespace: :nginx,
   role: :web,
   service: :nginx }].each do |config|
  namespace config[:namespace] do
    desc "Restart #{config[:service]} instance for this application"
    task :restart do
      on roles(config[:role]) do
        sudo 'service', fetch(config[:service]), 'restart'
      end
    end
    desc "Start #{config[:namespace]} instance for this application"
    task :start do
      on roles(config[:role]) do
        sudo "service #{fetch(config[:service])} start || true"
      end
    end
    desc "Show status of #{config[:namespace]} for this application"
    task :status do
      on roles(config[:role]) do
        sudo 'service', fetch(config[:service]), 'status'
      end
    end
    desc "Stop #{config[:namespace]} instance for this application"
    task :stop do
      on roles(config[:role]) do
        sudo 'service', fetch(config[:service]), 'stop'
      end
    end
  end
end

# Hack to fake a puma.rb config, which we do not have on a worker
before 'deploy:check:linked_files', :remove_junk do
  on roles(:db, :worker) do
    execute :touch, shared_path.join('puma.rb')
  end
end

after 'deploy:finished', 'puma:restart'
after 'deploy:finished', 'sidekiq:restart'
after 'deploy:finished', 'nginx:start'
