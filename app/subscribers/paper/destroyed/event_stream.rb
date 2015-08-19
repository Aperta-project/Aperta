class Paper::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    record.destroyed_payload
  end

end
