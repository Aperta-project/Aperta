module CasConfig
  def self.load_configuration
    opts = {
      'ssl'                      => ENV['CAS_SSL'].present?,
      'disable_ssl_verification' => ENV['CAS_DISABLE_SSL_VERIFICATION'].present?,
      'host'                     => ENV["CAS_HOST"],
      'port'                     => ENV["CAS_PORT"],
      'service_validate_url'     => ENV["CAS_SERVICE_VALIDATE_URL"],
    }

    opts['callback_url'] = ENV["CAS_CALLBACK_URL"] if ENV["CAS_CALLBACK_URL"].present?
    opts['logout_url'] = ENV["CAS_LOGOUT_URL"] if ENV['CAS_LOGOUT_URL'].present?
    opts['login_url'] = ENV["CAS_LOGIN_URL"] if ENV['CAS_LOGIN_URL'].present?
    opts['uid_field'] = ENV["CAS_UID_FIELD"] if ENV['CAS_UID_FIELD'].present?
    opts['ca_path'] = ENV["CAS_HOST"] if ENV['CAS_HOST'].present?

    opts
  end
end

Tahi::Application.configure do
  config.cas_enabled = ENV['CAS_ENABLED'] == 'true'

  if config.cas_enabled

    # enable for devise
    Devise.omniauth :cas, CasConfig.load_configuration

    # enable on the user model
    Rails.configuration.omniauth_providers << :cas
  end
end
