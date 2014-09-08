if defined?(MailSafe::Config)
  MailSafe::Config.replacement_address = ENV.fetch('MAILSAFE_REPLACEMENT_ADDRESS')
end
