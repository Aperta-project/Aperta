Tahi::Application.configure do
  if TahiEnv.cas_enabled?
    Devise.omniauth(
      :cas,
      'ssl' => TahiEnv.cas_ssl?,
      'ssl_verify' => TahiEnv.cas_ssl_verify?,
      'host' => TahiEnv.cas_host,
      'port' => TahiEnv.cas_port,
      'service_validate_url' => TahiEnv.cas_service_validate_url,
      'callback_url' => TahiEnv.cas_callback_url,
      'logout_url' => TahiEnv.cas_logout_url,
      'login_url' => TahiEnv.cas_login_url,
      'logout_full_url' =>
        URI.join(TahiEnv.cas_ssl? ? 'https://' : 'http://' +
                   TahiEnv.cas_host, TahiEnv.cas_logout_url).to_s)
    Rails.configuration.omniauth_providers << :cas
  end
end
