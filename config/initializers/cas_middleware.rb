Tahi::Application.configure do
  configuration = CasConfig.omniauth_configuration
  if configuration['enabled']
    Devise.omniauth(:cas, configuration)
    Rails.configuration.omniauth_providers << :cas
  end
end
