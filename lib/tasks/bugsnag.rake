namespace :bugsnag do
  desc 'Fetch afflicted user emails for a given bugsnag error'
  task :get_users_for_error, [:error_id, :days_ago] do |_, args|
    raise "Missing BUGSNAG_DATA_API_KEY env var" unless ENV['BUGSNAG_DATA_API_KEY']
    raise ArgumentError, "Missing Bugsnag Error ID" unless args[:error_id]
    # rubocop:disable Style/RescueModifier,Rails/TimeZone
    days_ago = Integer(args[:days_ago]) rescue 1
    time = Time.now - (days_ago * 24 * 3600)

    uri = URI.parse("https://api.bugsnag.com/errors/#{args[:error_id]}/events")
    uri.query = "per_page=999&start_time=#{time.iso8601}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "token #{ENV['BUGSNAG_DATA_API_KEY']}"
    response = http.request(request)

    parsed_data = JSON.parse(response.body)
    email_array = parsed_data.map { |event| event['meta_data']['User']['email'] }
    puts "Affected users:"
    puts email_array.uniq.join(', ')
  end
end
