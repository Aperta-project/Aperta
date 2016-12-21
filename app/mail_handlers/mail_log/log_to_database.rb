module MailLog
  # The LogToDatabase module is responsible for ensuring all emails
  # sent by the system are logged to the database.
  module LogToDatabase

    def self.attach_handlers!
      ::ActionMailer::Base.register_interceptor(DeliveringEmailInterceptor)
      ::ActionMailer::Base.register_observer(DeliveredEmailObserver)
    end

    class DeliveringEmailInterceptor
      def self.delivering_email(message)
        message.delivery_handler = EmailExceptionsHandler.new
        recipients = message.to.join(', ')
        EmailLog.create!(
          from: message.from.first,
          to: recipients,
          message_id: message.message_id,
          subject: message.subject,
          raw_source: message.to_s,
          status: 'pending'
        )
      end
    end

    class DeliveredEmailObserver
      def self.delivered_email(message)
        email_log = EmailLog.find_by!(message_id: message.message_id)
        email_log.update_column :status, 'sent'
      end
    end

    class EmailExceptionsHandler
      def deliver_mail(message, &blk)
        begin
          yield
        rescue Exception => ex
          email_log = EmailLog.find_by!(message_id: message.message_id)
          email_log.update_columns error_message: ex.message, status: 'failed'
          raise ex
        end
      end
    end

  end
end
