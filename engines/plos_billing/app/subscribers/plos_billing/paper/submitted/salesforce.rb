class PlosBilling::Paper::Submitted::Salesforce
  def self.call(_event_name, event_data)
    paper = event_data[:paper]

    SalesforceServices::API.delay.find_or_create_manuscript(paper_id: paper.id)
    SalesforceServices::API.delay.create_billing_and_pfa_case(paper_id: paper.id) if paper.billing_card
  end
end
