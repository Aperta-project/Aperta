class Invitation::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record
  end

  def payload
    destroyed_payload
  end

end
