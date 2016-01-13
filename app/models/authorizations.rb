# The Authorizations module houses the authorizations sub-system. The namespace
# is in part so we can isolate the authorization bits in code and in tests.
module Authorizations
  class << self
    # Yields an Authorizations::Configuration instance
    def configure(&blk)
      yield(configuration)
    end

    # Returns the current Authorizations::Configuration instance
    def configuration
      @configuration ||= Configuration.new
    end

    # Replaces the current Authorizations::Configuration instance with pristine
    # one. Note: This is primarily used so we can run a variety of tests
    # against the authorization sub-system.
    def reset_configuration
      @configuration = Configuration.new
    end
  end
end
