Tahi::Application.configure do
  config.x.cas = CasConfig.configuration

  if config.x.cas[:enabled]
    # enable for devise
    Devise.omniauth :cas, config.x.cas

    # enable on the user model
    Rails.configuration.omniauth_providers << :cas
  end
end
