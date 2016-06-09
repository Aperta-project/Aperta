# CasConfig is responsible for providing the configuration necessary to
# do SSO via CAS
module CasConfig
  def self.omniauth_configuration
    if TahiEnv.cas_enabled?
      {
        'enabled' => true,
        'ssl' => TahiEnv.cas_ssl?,
        'ssl_verify' => TahiEnv.cas_ssl_verify?,
        'host' => TahiEnv.cas_host,
        'port' => TahiEnv.cas_port,
        'service_validate_url' => TahiEnv.cas_service_validate_url,
        'callback_url' => TahiEnv.cas_callback_url,
        'logout_url' => TahiEnv.cas_logout_url,
        'login_url' => TahiEnv.cas_login_url
      }
    else
      { 'enabled' => false }
    end
  end
end
