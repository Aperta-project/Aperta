if defined?(MailSafe::Config) && Rails.env.staging?
  MailSafe::Config.replacement_address = 'tahi-dev+tahi-staging@neo.com'
end
