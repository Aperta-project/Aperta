HealthCheck.setup do |config|

  # uri prefix (no leading slash)
  config.uri = 'health'
  # health of the server can be checked by hitting (e.g) http://aperta.tech/health

  # Text output upon success
  config.success = "healthy"

  # status code used with plain text error message
  config.http_status_for_error_text = 500

  # status code used when json or xml is requested
  config.http_status_for_error_object = 500

  # ensure our databases are available:
  config.standard_checks = ['custom', 'database', 'sidekiq-redis']
  config.full_checks     = ['custom', 'database', 'sidekiq-redis']

  # max-age of response in seconds
  # cache-control is public when max_age > 1 and basic_auth_username is not set
  # You can force private without authentication for longer max_age by
  # setting basic_auth_username but not basic_auth_password
  config.max_age = 1

  config.add_custom_check('postgres-writability') do
    begin
      what_is_deposited = rand(42_000).to_s
      written_record    = Scratch.create(contents: what_is_deposited)
      read_record       = Scratch.find(written_record.id)
      what_is_withdrawn = read_record.contents

      if what_is_withdrawn == what_is_deposited
        "" # an empty string signals success!
      else
        "database write error"
      end

    rescue
      # if there's an exception, then we can assume the database has issues
      'database error'
    ensure
      written_record.delete
    end
  end

  config.add_custom_check('redis-writability') do
    Sidekiq.redis do |redis|
      begin
        what_is_deposited = rand(42_000).to_s
        scratch_key       = "scratch_key_#{what_is_deposited}"
        redis_response    = redis.set(scratch_key, what_is_deposited)
        what_is_withdrawn = redis.get(scratch_key)

        redis.del(scratch_key)

        if (what_is_withdrawn == what_is_deposited) && (redis_response == "OK")
          "" # an empty string signals success!
        else
          "redis write error"
        end
      rescue
        # if there's an exception, then we can assume redis has issues
        'redis error'
      end
    end
  end
end
