module Authorizations
  # Configuration houses the individual Authorization(s) being used to
  # configure the authorization sub-system.
  class Configuration

    # 'authorizations' returns the collection of authorization(s) that have \
    # been configured
    attr_accessor :authorizations

    def initialize
      @authorizations = []
    end

    # Creates an authorization thru the given assignment_to object and
    # options.
    def assignment_to(assignment_to, authorizes:, via:)
      @authorizations << Authorizations::Authorization.new(
        assignment_to: assignment_to,
        authorizes: authorizes,
        via: via
      )
    end
  end
end
