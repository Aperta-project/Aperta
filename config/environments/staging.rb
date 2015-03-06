require_relative 'production'
if ENV["DISABLE_SSL"]
  Tahi::Application.configure do
    config.force_ssl = false

    config.basic_auth_required = true
  end
end
