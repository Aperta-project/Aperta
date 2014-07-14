namespace :utils do
  require 'net/http'
  task :nudge => :environment do
    if ENV['PING_URL']
      uri = URI(ENV['PING_URL'])
      puts "Nudging #{uri}..."
      Net::HTTP.get_response(uri)
    end
  end
end
