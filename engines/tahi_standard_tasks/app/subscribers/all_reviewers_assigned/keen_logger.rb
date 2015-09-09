class AllReviewersAssigned::KeenLogger < KeenSubscriber

  def collection
    :papers
  end

  def payload
    reviewers = record.paper.reviewers

    {
      id: record.id,
      paper_id: record.paper.id,
      type: record.type,
      completed: record.completed,
      reviewer_count: reviewers.count,
      reviewers: reviewers.map do |reviewer|
          {
            id: reviewer.id,
            full_name: reviewer.full_name,
            user_name: reviewer.username
          }
      end
    }
  end

end
