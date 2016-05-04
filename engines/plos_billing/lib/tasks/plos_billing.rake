namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.ensure_pfa_case(paper_id: paper.id) if paper.billing_card
  end

  task :sync_em_guids => :environment do
    # Connection established manually here. If =PlosEditorialManager=
    # is used elsewhere, it must be established there as well.
    PlosEditorialManager.establish_connection(ENV['EM_DATABASE_URL'].present? ? ENV['EM_DATABASE_URL'] : "plos_editorial_manager_#{Rails.env}".to_sym)
    User.where(em_guid: nil).find_each do |user|
      em_match = PlosEditorialManager.find_person_by_email(email: user.email)

      if em_match.present? && em_match.size == 1
        guid = em_match.first["GUID"]

        puts "match for #{user.email} - #{guid}"
        user.update_attribute(:em_guid, guid)
      else
        puts "no match for #{user.email}"
      end
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
      bm    = BillingLog.new paper: paper, journal: paper.journal
      bm.to_s3 && puts("Uploaded #{bm.filename}")
    else
      puts "Missing paper_id. Please see usage instructions in #{__FILE__}"
    end
  end
end
