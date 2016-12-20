class LogEmailExceptionsToDatabaseHandler
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
