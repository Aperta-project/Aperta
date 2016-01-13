module Authorizations
  # The Authorization class houses an individual authorization.
  #
  # == Example: Getting access to tasks through paper
  #
  # In the below code you get access to a paper's tasks when you are assigned
  # to a paper, it will then look those up thru the :tasks association method
  # on the paper:
  #
  #     Authorization.new(
  #       assignment_to: Paper.name,
  #       authorizes: Task.name,
  #       via: :tasks
  #     )
  #
  class Authorization
    # 'assignment_to' is what a person is assigned to for this authorization \
    # to apply. It should be the name or (STI name) of the class
    attr_reader :assignment_to

    # 'authorizes' is what this authorization is authorizing. It should be \
    # the name or (STI name) of the ActiveRecord class
    attr_reader :authorizes

    # 'via' is the ActiveRecord association method (as a symbol) that tells \
    # how the authorized object can be looked up thru the assignment_to object.
    attr_reader :via

    def initialize(assignment_to:, authorizes:, via:)
      @assignment_to = assignment_to
      @authorizes = authorizes
      @via = via
    end
  end
end
