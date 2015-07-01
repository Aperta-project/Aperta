Tahi::Application.configure do
  config.password_auth_enabled = ENV['PASSWORD_AUTH_ENABLED'] == 'true'
end

