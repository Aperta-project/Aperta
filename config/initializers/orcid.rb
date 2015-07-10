Tahi::Application.configure do
  config.orcid_enabled = ENV['ORCID_ENABLED'] == 'true'

  if config.orcid_enabled
    config.orcid_key = ENV.fetch('ORCID_KEY')
    config.orcid_secret = ENV.fetch('ORCID_SECRET')

    # enable for devise
    Devise.omniauth :orcid, Rails.configuration.orcid_key, Rails.configuration.orcid_secret, strategy: OmniAuth::Strategies::Orcid

    # enable on the user model
    Rails.configuration.omniauth_providers << :orcid
  end
end
