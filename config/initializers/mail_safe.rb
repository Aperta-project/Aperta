if ENV.fetch('MAILSAFE_REPLACEMENT_ADDRESS').present?
  require 'mail_safe'
  MailSafe::Config.internal_address_definition =
    /^#{Regexp.quote(Rails.configuration.x.admin_email)}$/
  MailSafe::Config.replacement_address = ENV.fetch('MAILSAFE_REPLACEMENT_ADDRESS')
end
