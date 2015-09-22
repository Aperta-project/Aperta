class Author::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    AuthorsSerializer.new(record.paper.authors, root: :authors).as_json
  end

end
