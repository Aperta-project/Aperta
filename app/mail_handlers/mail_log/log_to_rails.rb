module MailLog
  # The LogToRails module is responsible for ensuring all emails
  # sent by the system are logged to the Rails logger.
  module LogToRails

    def self.attach_handlers!
      ::ActionMailer::Base.register_observer(DeliveredEmailObserver)
    end

    # Creates a log message after the email has been delivered
    class DeliveredEmailObserver
      def self.delivered_email(mail, logger: Rails.logger)
        recipients = mail.to.join(', ')
        logger.info "event=email to=#{recipients} from=#{mail.from.first} "\
                          "subject='#{mail.subject}' at=#{Time.current}"
      end
    end
  end
end
