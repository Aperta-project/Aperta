class Task::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    TaskSerializer.new(record).to_json
  end

end
