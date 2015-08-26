class Paper::Updated::EventStream < EventStreamSubscriber

  def channel
    record
  end

  def payload
    PaperSerializer.new(record).to_json
  end

end
