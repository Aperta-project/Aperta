class Author::Updated::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    record.payload
  end

end
