class CommentLook::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.user
  end

  def payload
    destroyed_payload
  end

end
