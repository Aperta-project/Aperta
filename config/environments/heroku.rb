require_relative 'staging'

Tahi::Application.configure do
  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  if ENV["HEROKU_PARENT_APP_NAME"].present?
    # this is only set for review apps. they end up with a domain like
    # "tahi-staging-pr-1786", which we can use to build up the asset host for
    # review apps
    review_app_host = "#{ENV["HEROKU_APP_NAME"]}.herokuapp.com"
    config.action_controller.asset_host = "//#{review_app_host}"
    config.action_mailer.default_url_options = { host: review_app_host }
  end
end
