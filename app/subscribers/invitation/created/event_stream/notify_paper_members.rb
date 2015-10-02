class Invitation::Created::EventStream::NotifyPaperMembers < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    InvitationSerializer.new(record).as_json
  end

end
