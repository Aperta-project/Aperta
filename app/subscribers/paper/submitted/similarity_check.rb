# fill me in
class Paper::Submitted::SimilarityCheck
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    previous_state = paper.previous_changes[:publishing_state][0]
    AutomatedSimilarityCheck.run(paper, previous_state)
  end
end
