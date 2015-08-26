class Task::Updated::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    TaskSerializer.new(record).to_json
  end

end
