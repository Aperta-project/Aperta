class Task::Created::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    TaskSerializer.new(record).to_json
  end

end
