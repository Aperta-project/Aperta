# Load DSL and set up stages
require 'capistrano/setup'

# Make formatting of cap output look pretty
require "airbrussh/capistrano"

# Include default deployment tasks
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/sidekiq'
require 'capistrano/puma'
require 'capistrano/maintenance'
require 'capistrano/npm'
require 'capistrano/bower'

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
