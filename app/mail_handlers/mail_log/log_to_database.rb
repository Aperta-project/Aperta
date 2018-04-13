# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
        recipients = get_recipients(message)
        mail_context = message.aperta_mail_context
        message_body = get_message(message)
        paper = mail_context.try(:paper)
        correspondence_hash = {
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
          paper: paper,
          journal: mail_context.try(:journal),
          additional_context: mail_context.try(:to_database_safe_hash)
        }
        correspondence_hash.merge!(
          manuscript_version: paper.versioned_texts.last.version,
          manuscript_status: paper.publishing_state,
          versioned_text_id: paper.versioned_texts.last.id
        ) if paper
        email_log = Correspondence.create!(correspondence_hash)
        message.attachments.each do |attachment|
          Dir.mktmpdir do |dir|
            file = File.new("#{dir}/#{attachment.filename}", 'w+')
            begin
              file.write(attachment.body.raw_source.force_encoding('UTF-8'))
              attachment = email_log.attachments.create!(file: file)
              attachment.create_resource_token!(attachment.file)
              attachment.update(status: 'done')
            ensure
              file.close
            end
          end
        end
      end

      def self.get_message(message)
        message.html_part ? message.html_part.body : message.body
      end

      def self.get_recipients(message)
        recipients = Array(message.to)
        users = User.where(email: recipients)
        emails = users.map(&:email).compact
        unknown = recipients - emails
        known = users.map { |user| "#{user.full_name} <#{user.email}>" }
        (known + unknown).join(', ')
      end
    end

    # Delivered Email Observer
    class DeliveredEmailObserver
      def self.delivered_email(message)
        email_log = Correspondence.find_by!(message_id: message.message_id)
        email_log.update!(
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
