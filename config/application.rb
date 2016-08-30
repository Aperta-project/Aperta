require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

require File.dirname(__FILE__) + '/../lib/tahi_env'
TahiEnv.validate!

module Tahi
  class Application < Rails::Application
    config.eager_load = true

    # use bin/rake tahi_standard_tasks:install:migrations
    # see http://guides.rubyonrails.org/engines.html#engine-setup
    # config.paths['db/migrate'].push 'engines/tahi_standard_tasks/db/migrate'

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/cli_utilities)
    config.autoload_paths += %W(#{config.root}/app/workers)
    config.autoload_paths += %W(#{config.root}/app/subscribers)

    config.s3_bucket = ENV.fetch('S3_BUCKET', :not_set)
    config.carrierwave_storage = :fog
    config.x.admin_email = TahiEnv.admin_email
    config.from_email = ENV.fetch('FROM_EMAIL', 'no-reply@example.com')

    config.salesforce_username = ENV.fetch('DATABASEDOTCOM_USERNAME', :not_set)
    config.salesforce_password = ENV.fetch('DATABASEDOTCOM_PASSWORD', :not_set)
    config.salesforce_client_id = ENV.fetch('DATABASEDOTCOM_CLIENT_ID', :not_set)
    config.salesforce_client_secret = ENV.fetch('DATABASEDOTCOM_CLIENT_SECRET', :not_set)
    config.salesforce_host = ENV.fetch('DATABASEDOTCOM_HOST', :not_set)

    # Raise an error within after_rollback & after_commit
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    if TahiEnv.basic_auth_required?
      config.basic_auth_user = TahiEnv.basic_http_username
      config.basic_auth_password = TahiEnv.basic_http_password
    end

    config.x.pusher_verbose_logging = TahiEnv.pusher_verbose_logging?

    config.omniauth_providers = []
  end
end
