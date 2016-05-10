require_relative 'production'

Tahi::Application.configure do
  # use overriden asset host from config
  config.action_controller.asset_host = ENV.fetch("RAILS_ASSET_HOST")
  config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }

  # Define how root_url should behave by default
  routes.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }
end
