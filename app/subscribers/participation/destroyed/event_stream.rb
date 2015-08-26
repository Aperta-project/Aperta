class Participation::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.task.paper
  end

  def payload
    destroyed_payload
  end

end
