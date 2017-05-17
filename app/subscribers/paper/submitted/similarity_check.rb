# fill me in
class Paper::Submitted::SimilarityCheck
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    previous_state = paper.previous_changes[:publishing_state][0]

    if previous_state == 'unsubmitted' ||
        previous_state == 'invited_for_full_submission'
      SimilarityChecker.maybe_run(paper)
    end
  end
end
