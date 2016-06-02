Tahi::Application.configure do
  if TahiEnv.orcid_enabled?
    # enable for devise
    Devise.omniauth \
      :orcid,
      TahiEnv.orcid_key,
      TahiEnv.orcid_secret,
      strategy: OmniAuth::Strategies::Orcid

    # enable on the user model
    Rails.configuration.omniauth_providers << :orcid
  end
end
