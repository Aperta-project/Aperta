module MailLog
  # The LogToDatabase module is responsible for ensuring all emails
  # sent by the system are logged to the database.
  module LogToDatabase
    def self.attach_handlers!
      ::ActionMailer::Base.register_interceptor(DeliveringEmailInterceptor)
      ::ActionMailer::Base.register_observer(DeliveredEmailObserver)
    end

    # Delivering Email Interceptor
    class DeliveringEmailInterceptor
      def self.delivering_email(message)
        message.delivery_handler = EmailExceptionsHandler.new
        recipients = message.to.join(', ')
        mail_context = message.aperta_mail_context
        message_body = get_message(message)
        Correspondence.create!(
          sender: message.from.first,
          recipients: recipients,
          message_id: message.message_id,
          subject: message.subject,
          body: message_body,
          # we need to do this instead of mail.without_attachments!
          # because without_attachments! mutates the message object
          raw_source: Mail.new(message.encoded).without_attachments!.to_s,
          status: 'pending',
          task: mail_context.try(:task),
          paper: mail_context.try(:paper),
          journal: mail_context.try(:journal),
          additional_context: mail_context.try(:to_database_safe_hash)
        )
      end

      def self.get_message(message)
        message.has_attachments? ? message.html_part.body : message.body
      end
    end

    # Delivered Email Observer
    class DeliveredEmailObserver
      def self.delivered_email(message)
        email_log = Correspondence.find_by!(message_id: message.message_id)
        email_log.update_columns(
          status: 'sent',
          sent_at: Time.now.utc
        )
      end
    end

    # Email Exceptions Handler
    # rubocop:disable Lint/RescueException
    class EmailExceptionsHandler
      def deliver_mail(message)
        yield
      rescue Exception => ex
        email_log = Correspondence.find_by!(message_id: message.message_id)
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
