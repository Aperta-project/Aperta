namespace :maintenance_mode do
  desc "Turn maintenance mode on"
  task :on do
    on roles(:app) do
      within release_path do
        execute "cp", "public/503.html", "public/system/maintenance.html"
      end
    end
  end

  desc "Turn maintenance mode off"
  task :off do
    on roles(:app) do
      within release_path do
        execute "rm", "public/system/maintenance.html"
      end
    end
  end
end
