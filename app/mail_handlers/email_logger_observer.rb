# Creates a log message after the email has been delivered
class EmailLoggerObserver
  def self.delivered_email(mail)
    recipients = mail.to.join(', ')
    Rails.logger.info "event=email to=#{recipients} from=#{mail.from.first} "\
                      "subject='#{mail.subject}' at=#{Time.current}"
  end
end
