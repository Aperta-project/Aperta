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
          execute :rsync, '-a', 'tmp/ember-cli/apps/client/assets/*', 'public/assets/'
        end
      end
    end
  end

  after :normalize_assets, :gzip_assets do
    on release_roles(fetch(:assets_roles)) do
      assets_path = release_path.join('public', fetch(:assets_prefix))
      execute :find, "#{assets_path}/ -type f -exec test ! -e {}.gz \\; -print0 | xargs -r -P8 -0 gzip --keep --best --quiet"
    end
  end
end

# Use service scripts to restart puma/sidekiq
[{ namespace: :puma,
   role: :app,
   service: :web_service_name },
 { namespace: :sidekiq,
   role: :worker,
   service: :worker_service_name }].each do |config|
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

namespace :nginx do
  desc "Restart nginx instance for this application"
  task :restart do
    on roles(:web) do
      sudo 'service', 'nginx', 'restart'
    end
  end
  desc "Start nginx instance for this application"
  task :start do
    on roles(:web) do
      sudo "service nginx start || true"
    end
  end
  desc "Show status of nginx for this application"
  task :status do
    on roles(:web) do
      sudo 'service', 'nginx', 'status'
    end
  end
  desc "Stop nginx instance for this application"
  task :stop do
    on roles(:web) do
      sudo 'service', 'nginx', 'stop'
    end
  end
end

namespace :cleanup do
  desc "Cleanup node temp files" # Prevents running out of inodes
  task :tmp do
    on release_roles(fetch(:assets_roles)) do
      execute :rm, '-rf', '/tmp/npm-*'
    end
  end
end

namespace :check_status do
  [{ name: :nginx,
     pidfile: :nginx_pidfile,
     role: :web
   },
   { name: :sidekiq,
     pidfile: :sidekiq_pidfile,
     role: :worker
   },
   { name: :puma,
     pidfile: :puma_pidfile,
     role: :web
   }].each do |config|
    desc "Check the status of the #{config[:name]} process"
    task config[:name] do
      on roles(config[:role]) do
        pidfile = fetch(config[:pidfile])
        if test("[ -s #{pidfile} ]") && test("ps -o pid= -p `< #{pidfile}`")
          info "#{config[:name]} is running"
        else
          error "#{config[:name]} is NOT running"
        end
      end
    end
  end
end

namespace :deploy do
  desc "Restart puma and sidekiq. Start nginx."
  task :restart do
    invoke 'puma:restart'
    invoke 'sidekiq:restart'
    invoke 'nginx:start'
  end

  desc "Check the status of puma, sidekiq, and nginx."
  task :check_statuses do
    invoke 'check_status:puma'
    invoke 'check_status:sidekiq'
    invoke 'check_status:nginx'
  end
end

# Hack to fake a puma.rb config, which we do not have on a worker
before 'deploy:check:linked_files', :remove_junk do
  on roles(:db, :worker) do
    execute :touch, shared_path.join('puma.rb')
  end
end

before 'deploy:migrate', :create_backup do
  on roles(:db) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        STDERR.puts 'Dumping database...'
        execute :rake, "db:dump"
        STDERR.puts "Dumped database backup to ~"
      end
    end
  end
end

after 'deploy:publishing', 'deploy:restart'
after 'deploy:restart', 'deploy:check_statuses'

after 'deploy:finished', 'cleanup:tmp'
