namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.ensure_pfa_case(paper_id: paper.id) if paper.billing_card
  end

  task :sync_em_guids => :environment do
    User.where(em_guid: nil).find_each do |user|
      guid = PlosEditorialManager.find_or_create_guid_by_email(email: user.email)
      puts "match for #{user.email} - #{guid}" if guid.present?
      puts "no match for #{user.email}" if guid.nil?
    end
  end

  # Usage:
  #   rake plos_billing:upload_log_file_to_s3[33]
  #   where:
  #     args[:paper_id] => "33"
  desc "Uploads a CSV billing log file to S3"
  task :upload_log_file_to_s3, [:paper_id] => :environment do |t, args|
    if args[:paper_id]
      paper = Paper.find args[:paper_id]
      bl =
        BillingLog.new(paper: paper, journal: paper.journal).populate_attributes
      if bl.save_and_send_to_s3
        puts("Uploaded #{bl.filename} \n #{bl.s3_url}")
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
    from_date = args[:from_date] || BillingLog.last.import_date if BillingLog.any?
    from_date = Date.parse(args[:from_date]) if args[:from_date]
    BillingLogManager.new(from_date: from_date).save_and_send_to_s3
    puts "Uploaded to #{BillingLog.last.s3_url}"
  end
end
