# Notify the system of assignment changes
class Assignment::NotifyAssignee < EventStreamSubscriber
  def channel
    private_channel_for(record.user)
  end

  def payload
    payload_for_record(record.assigned_to)
  end
end
