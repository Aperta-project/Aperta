class Invitation::Updated::EventStream::NotifyInvitee < EventStreamSubscriber

  def channel
    private_channel_for(record.invitee)
  end

  def payload
    InvitationIndexSerializer.new(record).to_json
  end

end
