module MailLog
  # The InitializeMessage module is responsible for initializing email
  # messages. This should likely be hooked into ActionMailer before any other
  # application-level email handlers are.
  module InitializeMessage

    def self.attach_handlers!
      ::ActionMailer::Base.register_interceptor(DeliveringEmailInterceptor)
    end

    class DeliveringEmailInterceptor
      def self.delivering_email(message)
        message.message_id ||= "<#{Mail.random_tag}@#{::Socket.gethostname}.mail>"
      end
    end

  end
end
