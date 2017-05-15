module MailLog
  module MailMessageExtensions
    extend ActiveSupport::Concern

    included do
      attr_accessor :aperta_mail_context
    end
  end
end
