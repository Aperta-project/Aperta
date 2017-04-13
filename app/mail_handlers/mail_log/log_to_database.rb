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
        mail_context = message.aperta_mail_context

        EmailLog.create!(
          sender: message.from.first,
          recipients: recipients,
          message_id: message.message_id,
          subject: message.subject,
          raw_source: message.without_attachments!.to_s,
          status: 'pending',
          task: mail_context.try(:task),
          paper: mail_context.try(:paper),
          journal: mail_context.try(:journal),
          additional_context: mail_context.try(:to_database_safe_hash)
        )
      end
    end

    class DeliveredEmailObserver
      def self.delivered_email(message)
        email_log = EmailLog.find_by!(message_id: message.message_id)
        email_log.update_columns(
          status: 'sent',
          sent_at: Time.now.utc
        )
      end
    end

    class EmailExceptionsHandler
      def deliver_mail(message, &blk)
        begin
          yield
        rescue Exception => ex
          email_log = EmailLog.find_by!(message_id: message.message_id)
          email_log.update_columns(
            error_message: ex.message,
            errored_at: Time.now.utc,
            status: 'failed'
          )
          raise ex
        end
      end
    end
  end
end
