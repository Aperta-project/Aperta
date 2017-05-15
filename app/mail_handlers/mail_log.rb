# mail is auto-required by Rails later, but we need it available
# sooner
require 'mail'

module MailLog
  def self.apply_mail_logging_extensions!
    ::ApplicationMailer.send :include, ActionMailerLoggingExtensions
    ::Mail::Message.send :include, MailMessageExtensions
  end
end
