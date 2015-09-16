class PlosAuthors::PlosAuthor::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    PlosAuthors::PlosAuthorsSerializer.new(record.plos_authors_task.plos_authors, root: :plos_authors).as_json
  end

end
