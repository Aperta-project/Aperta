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
  config.standard_checks = [ 'database', 'redis' ]
  config.full_checks     = [ 'database', 'redis' ]

  # max-age of response in seconds
  # cache-control is public when max_age > 1 and basic_auth_username is not set
  # You can force private without authentication for longer max_age by
  # setting basic_auth_username but not basic_auth_password
  config.max_age = 1

end
