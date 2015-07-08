require_relative 'production'

Tahi::Application.configure do
  config.basic_auth_required = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "//assets.example.com"
  config.action_controller.asset_host = ENV.fetch("RAILS_ASSET_HOST")

  # Enable skylight.io
  config.skylight.environments += ['staging']
end
