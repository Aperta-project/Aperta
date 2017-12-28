namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |_task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.ensure_pfa_case(paper_id: paper.id) if paper.billing_card
  end

  # Usage:
  #   rake plos_billing:upload_log_file_to_s3[33]
  #   where:
  #     args[:paper_id] => "33"
  desc "Uploads a CSV billing log file to S3"
  task :upload_log_file_to_s3, [:paper_id] => :environment do |_t, args|
    if args[:paper_id]
      Rails.logger.info "Starting Billing csv upload to S3 job"
      paper = Paper.find args[:paper_id]
      bl =
        BillingLog.new(paper: paper).populate_attributes
      if bl.save_and_send_to_s3!
        puts("Uploaded #{bl.filename} \n #{bl.csv_file.url}")
      else
        puts("Error in saving file for paper id: #{args[:paper_id]}")
      end
    else
      puts "Missing paper_id. Please see usage instructions in #{__FILE__}"
    end
  end

  # Usage:
  #   rake 'plos_billing:generate_billing_log'
  desc "Generate a billing log file"
  task :generate_billing_log do |_t, _args|
    Rails.logger.info "Starting Billing log job"
    report = BillingLogReport.create!

    if report.papers?
      report.save_and_send_to_s3!
      puts "Uploaded to #{report.csv_file.url}"
    else
      puts 'There were no accepted papers with billing tasks left to process'
    end
  end
end
