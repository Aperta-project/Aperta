Tahi::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  # config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Mailcatcher configuration
  config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

  # defaults to local storage
  # config.carrierwave_storage = :fog
  config.session_store :cookie_store, key: '_tahi_session'

  # compress logging output
  # config.lograge.enabled = true

  config.log_level = :info

  config.carrierwave_storage = :fog

  config.action_mailer.default_url_options = {host: "localhost", port: 5000, protocol: "http://"}

  # Define how root_url should behave by default
  routes.default_url_options = {
    host: "localhost",
    port: 5000,
    protocol: "http://"
  }

  if defined? Bullet
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.console = true
      Bullet.rails_logger = true
      Bullet.add_footer = true
      Bullet.stacktrace_includes = ['tahi_standard_tasks', 'plos_bio_tech_check', 'plos_bio_internal_review', 'plos_billing', 'tahi-assign_team']
    end
  end
end
