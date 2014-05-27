namespace :api do
  desc "Generate new access token"
  task generate_access_token: :environment do
    $stdout.puts "API key: " + ApiKey.generate_access_token
  end
end
