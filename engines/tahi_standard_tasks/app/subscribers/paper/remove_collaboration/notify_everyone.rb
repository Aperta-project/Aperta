# Notify everyone of the collaboration change
class Paper::RemoveCollaboration::NotifyEveryone < EventStreamSubscriber
  def channel
    private_channel_for(record)
  end

  def payload
    payload_for_record record
  end

  def action
    'added'
  end
end
