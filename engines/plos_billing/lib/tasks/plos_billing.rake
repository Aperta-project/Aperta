namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.create_billing_and_pfa_case(paper_id: paper.id) if paper.billing_card
  end

  task :sync_em_guids => :environment do
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

end
