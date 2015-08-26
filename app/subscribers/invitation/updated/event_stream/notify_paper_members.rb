class Invitation::Updated::EventStream::NotifyPaperMembers < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    InvitationSerializer.new(record).to_json
  end

end
