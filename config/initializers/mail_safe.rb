if defined?(MailSafe::Config)
  feedback_email_address = ENV.fetch("ADMIN_EMAIL")
  MailSafe::Config.internal_address_definition = /^#{Regexp.quote(feedback_email_address)}$/
  MailSafe::Config.replacement_address = ENV.fetch('MAILSAFE_REPLACEMENT_ADDRESS')
end
