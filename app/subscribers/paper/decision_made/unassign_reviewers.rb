class Paper::DecisionMade::UnassignReviewers

  def self.call(_event_name, event_data)
    paper = event_data[:record]

    paper.reviewers.each do |reviewer|
      paper.unassign_reviewer reviewer
    end
  end
end
