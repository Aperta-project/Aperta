# Notify everyone of the collaboration change
class Paper::AddCollaboration::NotifyEveryone < EventStreamSubscriber
  def channel
    private_channel_for(record)
  end

  def payload
    payload_for_record record
  end

  def action
    'updated'
  end
end
