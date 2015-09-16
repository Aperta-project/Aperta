class AllReviewersAssigned::ReportingEventLogger < ReportingEventSubscriber

  def build_event
    paper = record.paper
    reviewers = paper.reviewers

    ReportingEvent.new do |es|
      es.name = :all_reviewers_assigned
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
