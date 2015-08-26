class Paper::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record)
  end

  def payload
    PaperSerializer.new(record).to_json
  end

end
