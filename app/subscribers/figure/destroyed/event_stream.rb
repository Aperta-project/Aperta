class Figure::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    destroyed_payload
  end

end
