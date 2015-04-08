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

    root.join('vendor', 'assets', 'bower_components').to_s.tap do |bower_path|
      config.sass.load_paths << bower_path
      config.assets.paths << bower_path
    end
    # Precompile Bootstrap fonts
    config.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
    # Minimum Sass number precision required by bootstrap-sass
    ::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max

    config.s3_bucket = ENV.fetch('S3_BUCKET', :not_set)
    config.carrierwave_storage = :fog
    config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }
    config.admin_email = ENV.fetch('ADMIN_EMAIL')

    # Raise an error within after_rollback & after_commit
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    config.basic_auth_required = ENV.fetch("BASIC_AUTH_REQUIRED", false)
    if config.basic_auth_required
      config.basic_auth_user = ENV.fetch('BASIC_HTTP_USERNAME')
      config.basic_auth_password = ENV.fetch('BASIC_HTTP_PASSWORD')
    end
  end
end
