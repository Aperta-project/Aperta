class Invitation::Created::EventStream::NotifyPaperMembers < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    InvitationSerializer.new(record).to_json
  end

end
