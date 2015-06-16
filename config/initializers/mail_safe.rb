if defined?(MailSafe::Config)
  MailSafe::Config.internal_address_definition = Proc.new { false }
  MailSafe::Config.replacement_address = ENV.fetch('MAILSAFE_REPLACEMENT_ADDRESS')
end
