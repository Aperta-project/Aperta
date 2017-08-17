# Configuration for Rack::Timeout
class Application < Rails::Application
  # config.middleware.use Rack::Timeout
end

# Rack::Timeout.timeout = Integer(ENV["RACK_TIMEOUT"] || 30) # seconds
