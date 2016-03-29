module CasConfig
  def self.load_configuration
    opts = {
      'ssl'                      => ENV['CAS_SSL'].present?,
      'disable_ssl_verification' => ENV['CAS_DISABLE_SSL_VERIFICATION'].present?,
      'host'                     => ENV['CAS_HOST'],
      'port'                     => ENV['CAS_PORT'],
      'service_validate_url'     => ENV['CAS_SERVICE_VALIDATE_URL']
    }

    opts['callback_url'] = ENV['CAS_CALLBACK_URL'] if ENV['CAS_CALLBACK_URL'].present?
    opts['logout_url'] = ENV['CAS_LOGOUT_URL'] || '/cas/logout'
    opts['login_url'] = ENV['CAS_LOGIN_URL'] if ENV['CAS_LOGIN_URL'].present?
    opts['uid_field'] = ENV['CAS_UID_FIELD'] if ENV['CAS_UID_FIELD'].present?
    opts['ca_path'] = ENV['CAS_CA_PATH'] if ENV['CAS_CA_PATH'].present?
    opts['ssl'] = ENV['CAS_SSL'] || true

    if %w(host logout_url ssl).all? { |k| opts[k].present? }
      scheme = opts['ssl'] ? 'https://' : 'http://'
      opts['logout_full_url'] = URI.join(scheme + opts['host'],
                                         opts['logout_url']).to_s
    end

    opts
  end
end

Tahi::Application.configure do
  config.x.cas = CasConfig.load_configuration

  if ENV['CAS_ENABLED'] == 'true'
    # enable for devise
    Devise.omniauth :cas, config.x.cas

    # enable on the user model
    Rails.configuration.omniauth_providers << :cas
  end
end
