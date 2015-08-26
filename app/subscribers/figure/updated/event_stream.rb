class Figure::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    FigureSerializer.new(record).as_json
  end

end
