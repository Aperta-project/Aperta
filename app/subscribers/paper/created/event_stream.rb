class Paper::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record)
  end

  def payload
    PaperSerializer.new(record).as_json
  end

end
