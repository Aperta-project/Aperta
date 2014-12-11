CAS_CONFIG = if ENV['CAS_HOST']
               retval = {
                 # booleans
                 'ssl'                      => ENV['CAS_SSL'].present?,
                 'disable_ssl_verification' => ENV['CAS_DISABLE_SSL_VERIFICATION'].present?
               }
               %w(host port service_validate_url callback_url logout_url
                  login_url uid_field ca_path).each do |key|
                 val = ENV["CAS_#{key.upcase}"]
                 retval[key] = val if val
               end
               retval
             else
               YAML.load_file(File.join(Rails.root, 'config', 'cas.yml'))[Rails.env]
             end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, CAS_CONFIG
end
