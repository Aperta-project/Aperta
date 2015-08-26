class Participation::Created::EventStream < EventStreamSubscriber

  def channel
    record.task.paper
  end

  def payload
    ParticipationSerializer.new(record).to_json
  end

end
