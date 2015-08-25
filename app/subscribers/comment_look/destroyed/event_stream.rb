class CommentLook::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.user
  end

  def payload
    record.destroyed_payload
  end

end
