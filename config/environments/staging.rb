require_relative 'production'

Tahi::Application.configure do
  config.basic_auth_required = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  if ENV["HEROKU_PARENT_APP_NAME"].present?
    # this is only set for review apps. they end up with a domain like
    # "tahi-staging-pr-1786", which we can use to build up the asset host for
    # review apps
    review_app_host = "#{ENV["HEROKU_APP_NAME"]}.herokuapp.com"
    config.action_controller.asset_host = "//#{review_app_host}"
    config.action_mailer.default_url_options = { host: review_app_host }
  else
    # use overriden asset host from config
    config.action_controller.asset_host = ENV.fetch("RAILS_ASSET_HOST")
    config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }

    # Define how root_url should behave by default
    routes.default_url_options = { host: ENV.fetch('DEFAULT_MAILER_URL') }
  end
end
