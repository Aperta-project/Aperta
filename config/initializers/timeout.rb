# Configuration for Rack::Timeout
class Application < Rails::Application
  config.middleware.use Rack::Timeout
end

Rack::Timeout.timeout = 20 # seconds
