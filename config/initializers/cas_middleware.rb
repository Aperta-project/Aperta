CAS_CONFIG = YAML.load_file("#{Rails.root}/config/cas.yml")[Rails.env]
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, CAS_CONFIG
end

