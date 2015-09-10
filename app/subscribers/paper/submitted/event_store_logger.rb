class Paper::Submitted::EventStoreLogger < EventStoreSubscriber

  def build_event
    EventStore.new do |es|
      es.journal_id = record.journal_id
      es.paper_id = record.id
      es.data = {
        doi: record.doi,
        short_title: record.short_title,
        paper_type: record.paper_type,
        publishing_state: record.publishing_state,
        submitted_at: record.submitted_at,
        creator: {
          id: record.creator.id,
          username: record.creator.username,
          full_name: record.creator.full_name,
        }
      }
    end
  end

end
