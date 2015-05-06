require_relative 'production'

Tahi::Application.configure do
  config.force_ssl = false if ENV["DISABLE_SSL"]
  config.basic_auth_required = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "//assets.example.com"
  config.action_controller.asset_host = ENV.fetch("RAILS_ASSET_HOST")

  config.action_mailer.delivery_method = :smtp

  # Mailtrap Configurations, they can be retrieved from "https://mailtrap.io/api/v1/inboxes.json?api_token=ENV['MAILTRAP_API_TOKEN']"
  # or you can run "heroku addons:open mailtrap --app $app_name" to get them from the dashboard
  # MAILTRAP_API_TOKEN is generated when the addon is created on heroku
  config.action_mailer.smtp_settings = {
      address: 'mailtrap.io',
      port: '2525',
      authentication: :cram_md5,
      user_name: ENV.fetch('MAILTRAP_USERNAME'),
      password: ENV.fetch('MAILTRAP_PASSWORD'),
      domain: 'mailtrap.io',
      enable_starttls_auto: true
  }
end
