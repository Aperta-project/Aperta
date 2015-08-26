class Figure::Updated::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    FigureSerializer.new(record).to_json
  end

end
