require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

module Tahi
  class Application < Rails::Application
    config.eager_load = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/workers)
    config.assets.initialize_on_precompile = true
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

    config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'images')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')

    config.s3_bucket = ENV.fetch('S3_BUCKET', :not_set)
    config.carrierwave_storage = :fog
    config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }

    # Raise an error within after_rollback & after_commit
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    config.basic_auth_required = ENV.fetch("BASIC_AUTH_REQUIRED", false)
    if config.basic_auth_required
      config.basic_auth_user = ENV.fetch('BASIC_HTTP_USERNAME')
      config.basic_auth_password = ENV.fetch('BASIC_HTTP_PASSWORD')
    end

    ActionMailer::Base.smtp_settings = {
      address: 'smtp.sendgrid.net',
      port: '587',
      authentication: :plain,
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'],
      domain: 'heroku.com',
      enable_starttls_auto: true
    }
  end
end
