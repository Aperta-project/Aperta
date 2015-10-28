namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.create_billing_and_pfa_case(paper_id: paper.id) if paper.billing_card
  end

  # Usage:
  #   rake plos_billing:upload_log_file_to_s3[33]
  #   where:
  #     args[:paper_id] => "33"
  desc "Uploads a CSV billing log file to S3"
  task :upload_log_file_to_s3, [:paper_id] => :environment do |t, args|
    if args[:paper_id]
      paper = Paper.find args[:paper_id]
      bm    = PlosServices::BillingLogManager.new paper: paper
      bm.to_s3 && puts("Uploaded #{bm.filename}")
    else
      puts "Missing paper_id. Please see usage instructions in #{__FILE__}"
    end
  end
end
