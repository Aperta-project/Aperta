namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.ensure_pfa_case(paper_id: paper.id) if paper.billing_card
  end

  # Usage:
  #   rake plos_billing:upload_log_file_to_s3[33]
  #   where:
  #     args[:paper_id] => "33"
  desc "Uploads a CSV billing log file to S3"
  task :upload_log_file_to_s3, [:paper_id] => :environment do |t, args|
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
  #   rake 'plos_billing:generate_billing_log[2020-05-30]''
  desc "Generate a billing log file with an optional from_date of YYYY-MM-DD"
  task :generate_billing_log, [:from_date] => :environment do |t, args|
    Rails.logger.info "Starting Billing log job"
    date = Date.parse(args[:from_date]) if args[:from_date].present?
    report = BillingLogReport.create_report(from_date: date)

    if report.papers?
      report.save_and_send_to_s3!
      puts "Uploaded to #{report.csv_file.url}"
    else
      puts 'There were no accepted papers with billing tasks left to process'
    end
  end

  # Set to run each day exporting completed billing tasks in the last day
  desc 'Automated billing export and ftp to designated billing host'
  task daily_billing_log_export: :environment do
    Rails.logger.info "Starting Billing log job"
    date = Time.zone.now.utc.days_ago(1).beginning_of_day
    report = BillingLogReport.create_report(from_date: date)

    report.print unless Rails.env.test?
    report.save_and_send_to_s3!
    BillingFTPUploader.new(report).upload
  end
end
