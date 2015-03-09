require_relative 'production'

Tahi::Application.configure do
  config.force_ssl = false if ENV["DISABLE_SSL"]

  config.basic_auth_required = true
end
