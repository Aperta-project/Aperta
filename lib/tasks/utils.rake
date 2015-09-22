namespace :utils do
  require 'net/http'
  task :nudge => :environment do
    if ENV['PING_URL']
      uri = URI(ENV['PING_URL'])
      puts "Nudging #{uri}..."
      Net::HTTP.get_response(uri)
    end
  end

  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |task, args|
    paper = Paper.find(args[:paper_id])
    paper.create_billing_and_pfa_case
    puts "#create_billing_and_pfa_case"
  end
end
