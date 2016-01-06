module Authorizations
  # Holds authorizations
  class Authorization
    attr_reader :assignment_to, :authorizes, :via

    def initialize(assignment_to:, authorizes:, via:)
      @assignment_to = assignment_to
      @authorizes = authorizes
      @via = via
    end
  end
end
