namespace :tahi do
  namespace :api do
    desc "Generate new access token"
    task generate_access_token: :environment do
      $stdout.puts "API Key: " + ApiKey.generate!
    end
  end
end
