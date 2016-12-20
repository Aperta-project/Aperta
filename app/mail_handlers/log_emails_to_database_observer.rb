class LogEmailsToDatabaseObserver
  def self.delivered_email(message)
    email_log = EmailLog.find_by!(message_id: message.message_id)
    email_log.update_column :status, 'sent'
  end
end
