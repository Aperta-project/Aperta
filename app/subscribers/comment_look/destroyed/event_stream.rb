class CommentLook::Destroyed::EventStream < EventStreamSubscriber

  def channel
    system_channel
  end

  def payload
    destroyed_payload
  end

end
