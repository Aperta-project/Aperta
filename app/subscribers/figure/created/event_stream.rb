class Figure::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    FigureSerializer.new(record).to_json
  end

end
