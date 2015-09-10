class AllReviewersAssigned::EventStoreLogger < EventStoreSubscriber

  def build_event
    paper = record.paper
    reviewers = paper.reviewers

    EventStore.new do |es|
      es.journal_id = paper.journal_id
      es.paper_id = paper.id
      es.data = {
        completed: record.completed,
        reviewer_count: reviewers.count,
        reviewers: reviewers.map do |reviewer|
            {
              id: reviewer.id,
              full_name: reviewer.full_name,
              username: reviewer.username
            }
        end
      }
    end
  end

end
