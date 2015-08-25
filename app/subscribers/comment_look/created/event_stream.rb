class CommentLook::Created::EventStream < EventStreamSubscriber

  def channel
    record.user
  end

  def payload
    owner = record.user
    record.payload(user: owner)
  end

end
