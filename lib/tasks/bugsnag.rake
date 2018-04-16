# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

namespace :bugsnag do
  desc <<-DESC
    Fetch afflicted user emails for a given bugsnag error.
    First argument is the bugsag error id. The second is
    an optional integer indicating how long ago the query
    should search. It defaults to 1 day ago. Requires an API key
    environmental var for accessing bugsnag data. For more information see
    https://confluence.plos.org/confluence/display/TAHI/Bugsnag+Integration
  DESC

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
