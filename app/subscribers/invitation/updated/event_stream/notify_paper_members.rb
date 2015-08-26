class Invitation::Updated::EventStream::NotifyPaperMembers < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    InvitationSerializer.new(record).to_json
  end

end
