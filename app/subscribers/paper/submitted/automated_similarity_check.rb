# fill me in
class Paper::Submitted::AutomatedSimilarityCheck
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    previous_state = paper.previous_changes[:publishing_state][0]
    AutomatedSimilarityCheck.new(paper, previous_state).run
  end
end
