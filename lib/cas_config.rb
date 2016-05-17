# Loads the configurations for CAS
class CasConfig
  def self.load_configuration
    opts = { enabled: TahiEnv.cas_enabled? }.with_indifferent_access

    if opts[:enabled]
      opts.merge!(
        'ssl'                   => TahiEnv.cas_ssl?,
        'ssl_verify'            => TahiEnv.cas_ssl_verify?,
        'host'                  => TahiEnv.cas_host,
        'port'                  => TahiEnv.cas_port,
        'service_validate_url'  => TahiEnv.cas_service_validate_url,
        'callback_url'          => TahiEnv.cas_callback_url,
        'logout_url'            => TahiEnv.cas_logout_url,
        'login_url'             => TahiEnv.cas_login_url,
        'logout_full_url'       => logout_full_url
      )
    end

    opts
  end

  def self.logout_full_url
    scheme = TahiEnv.cas_ssl? ? 'https://' : 'http://'
    URI.join(scheme + TahiEnv.cas_host, TahiEnv.cas_logout_url).to_s
  end
end
