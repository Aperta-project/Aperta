module Authorizations
  # Configuration system for authorizations
  class Configuration
    attr_accessor :authorizations

    def initialize
      @authorizations = []
    end

    def assignment_to(assignment_to, authorizes:, via:)
      @authorizations << Authorizations::Authorization.new(
        assignment_to: assignment_to,
        authorizes: authorizes,
        via: via
      )
    end
  end
end
