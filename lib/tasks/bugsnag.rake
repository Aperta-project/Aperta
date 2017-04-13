namespace :bugsnag do
  desc 'Fetch afflicted user emails for a given bugsnag error'
  # for more info on keys or integration see
  # https://confluence.plos.org/confluence/display/TAHI/Bugsnag+Triage
  task :get_users_for_error, [:error_id, :days_ago] do |_, args|
    raise "Missing BUGSNAG_DATA_API_KEY env var" unless ENV['BUGSNAG_DATA_API_KEY']
    raise ArgumentError, "Missing Bugsnag Error ID" unless args[:error_id]
    # rubocop:disable Style/RescueModifier,Rails/TimeZone
    days_ago = Integer(args[:days_ago]) rescue 1
    time = Time.now - (days_ago * 24 * 3600)

    conn = Faraday.new(url: 'https://api.bugsnag.com')

    response = conn.get do |req|
      req.url "/errors/#{args[:error_id]}/events"
      req.params['per_page'] = 999
      req.params['start_time'] = time.iso8601
      req.headers['Authorization'] = "token #{ENV['BUGSNAG_DATA_API_KEY']}"
    end

    if response.status == 200
      parsed_data = JSON.parse(response.body)
      email_array = parsed_data.map { |event| event['meta_data']['User']['email'] }
      puts "Affected users:"
      puts email_array.uniq.join(', ')
    else
      puts "Response code #{response.status}"
    end
  end
end
