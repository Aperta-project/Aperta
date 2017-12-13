class PlosBilling::Paper::Salesforce
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    PlosBilling::SalesforceManuscriptUpdateWorker.perform_async(paper.id)
  end
end
