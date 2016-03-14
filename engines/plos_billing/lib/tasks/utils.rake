namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.ensure_pfa_case(paper_id: paper.id) if paper.billing_card
  end
end
