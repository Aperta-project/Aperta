require_relative 'production'

Tahi::Application.configure do
  config.basic_auth_required = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  if ENV["HEROKU_APP_NAME"].present?
    # this is only set for review apps. they end up with a domain like
    # "tahi-staging-pr-1786", which we can use to build up the asset host for
    # review apps
    config.action_controller.asset_host = "//#{ENV["HEROKU_APP_NAME"]}.herokuapp.com"
  else
    # use overriden asset host from config
    config.action_controller.asset_host = ENV["RAILS_ASSET_HOST"]
  end
end
