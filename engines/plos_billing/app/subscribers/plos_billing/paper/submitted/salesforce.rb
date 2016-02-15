class PlosBilling::Paper::Submitted::Salesforce
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    PlosBilling::ManuscriptUpdateWorker.perform_async(paper.id)
  end
end
