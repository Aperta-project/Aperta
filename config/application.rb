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
    config.s3_bucket = ENV.fetch('S3_BUCKET', :not_set)
    config.carrierwave_storage = :fog
    config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }

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
