class CommentLook::Created::EventStream < EventStreamSubscriber

  def channel
    record.user
  end

  def payload
    owner = record.user
    CommentLookSerializer.new(record, user: owner).to_json
  end

end
