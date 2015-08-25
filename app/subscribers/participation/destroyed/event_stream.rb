class Participation::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.task.paper
  end

  def payload
    record.destroyed_payload
  end

end
