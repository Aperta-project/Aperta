class LogEmailsToDatabaseInterceptor
  def self.delivering_email(message)
    message.message_id = "<#{Mail.random_tag}@#{::Socket.gethostname}.mail>"
    message.delivery_handler = LogEmailExceptionsToDatabaseHandler.new
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
