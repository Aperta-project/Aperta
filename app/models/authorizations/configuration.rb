module Authorizations
  # An Authorizations::Configuration houses the individual Authorization(s)
  # being used to configure the authorization sub-system.
  module Configuration
    extend self

    # 'authorizations' returns the collection of authorization(s) that have \
    # been configured
    attr_accessor :authorizations

    # Creates an authorization thru the given assignment_to object and
    # options.
    def assignment_to(assignment_to, authorizes:, via:)
      @authorizations ||= []
      @authorizations << Authorizations::Authorization.new(
        assignment_to: assignment_to,
        authorizes: authorizes,
        via: via
      )
    end

    # Clears out any currently configured Authorizations.
    def reset
      @authorizations = []
    end

    # Reloads the application's default Authorizations from
    # config/initializers/z_authorizations.rb
    def reload
      reset
      load 'config/initializers/z_authorizations.rb'
    end
  end
end
