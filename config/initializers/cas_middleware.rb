module CasConfig
  def self.extract_environment_variables
    {
      'ssl'                      => ENV['CAS_SSL'].present?,
      'disable_ssl_verification' => ENV['CAS_DISABLE_SSL_VERIFICATION'].present?,
      'host'                     => ENV["CAS_HOST"],
      'port'                     => ENV["CAS_PORT"],
      'service_validate_url'     => ENV["CAS_SERVICE_VALIDATE_URL"],
      'callback_url'             => ENV["CAS_CALLBACK_URL"],
      'logout_url'               => ENV["CAS_LOGOUT_URL"],
      'login_url'                => ENV["CAS_LOGIN_URL"],
      'uid_field'                => ENV["CAS_UID_FIELD"],
      'ca_path'                  => ENV["CAS_HOST"]
    }
  end

  def self.load_configuration
    if ENV['CAS_HOST'].present?
      CasConfig.extract_environment_variables
    else
      YAML.load_file(File.join(Rails.root, 'config', 'cas.yml'))[Rails.env]
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, CasConfig.load_configuration
end

Rails.configuration.omniauth_providers << :cas
