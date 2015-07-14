set :rails_env, "production"
set :rack_env, "production"

# deploy checked out branch
set :branch, `git rev-parse --abbrev-ref HEAD`.strip

# deploy correct dotenv .env file
set :linked_files, fetch(:linked_files, []).push('.env.production')

role :app, %w(deploy@production-ec2.tahi-project.org)
role :web, %w(deploy@production-ec2.tahi-project.org)
role :db, %w(deploy@production-ec2.tahi-project.org)
