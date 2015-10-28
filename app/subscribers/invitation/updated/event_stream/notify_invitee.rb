class Invitation::Updated::EventStream::NotifyInvitee < EventStreamSubscriber

  def channel
    private_channel_for(record.invitee)
  end

  def run
    super if record.invitee
  end

end
