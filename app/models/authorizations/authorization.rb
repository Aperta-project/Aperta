module Authorizations
  # The Authorization class defines what it means to be assigned to
  # a particular type of object.
  #
  # The current Authorization sub-system requires an explicit pathway be
  # defined for accessing objects.
  #
  # For example, consider a user assigned to a Journal with a role that has
  # :view permissions on a Paper. If they are trying to view a Paper
  # that belongs to that journal the Authorizations sub-system needs to know
  # where to look. What should it consider as the journal's papers?
  #
  # In ActiveRecord-land this is easy, there's likely a has_many :papers
  # association on Journal. Rather than assume that exists the Authorizations
  # sub-system needs to be told that it exists and that it should be used
  # to authorize Papers when the user is assigned to a Journal.
  #
  # An Authorization instance represents a single pathway for how to get from
  # point A (e.g. a journal) to point B (e.g.a journal's papers).
  #
  # == Example: Getting access papers through a journal
  #
  # In the below code you get access to a paper's tasks when you are assigned
  # to a paper, it will then look those up thru the :tasks association method
  # on the paper:
  #
  #     Authorization.new(
  #       assignment_to: Journal,
  #       authorizes: Paper,
  #       via: :papers
  #     )
  #
  # == Example: Getting access to tasks through paper
  #
  # In the below code you get access to a paper's tasks when you are assigned
  # to a paper, it will then look those up thru the :tasks association method
  # on the paper:
  #
  #     Authorization.new(
  #       assignment_to: Paper,
  #       authorizes: Task,
  #       via: :tasks
  #     )
  #
  # == Note:
  #
  # One limitation of the current Authorization sub-system is that the value
  # passed for :via must point to a defined association.
  #
  class Authorization
    # 'via' is the ActiveRecord association method (as a symbol) that tells \
    # how the authorized object can be looked up thru the assignment_to object.
    attr_reader :via

    def initialize(assignment_to:, authorizes:, via:)
      # We're storing these as strings since Ruby changes object_id on reload
      @assignment_to = assignment_to.to_s
      @authorizes = authorizes.to_s
      @via = via
    end

    # 'assignment_to' returns the class that this authorization instance
    # requires an assignment for.
    def assignment_to
      @assignment_to.constantize
    end

    # 'authorizes' returns the class that this authorization instance
    # authorizes.
    def authorizes
      @authorizes.constantize
    end

    # 'inverse_of_via' returns the association on @authorizes which is the
    # inverse of the association represented by @via.
    # This can be used to traverse the authorization chain backwards.
    # Returns either the association name that is the inverse relationship
    # or nil.
    def inverse_of_via
      assignment_to.reflections[via.to_s].try(:inverse_of).try(:name)
    end

    def reflection
      assignment_to.reflections[via.to_s]
    end
  end
end
