# This file must load after the devise initializer.
#
# This configuration defines how you get access to object based on your
# assignments.
#
# For example, if somebody is assigned to a Journal and they are trying to
# load the papers they have access to, this is used to tell the authorization
# subsystem that a user assigned to a Journal trying to access Paper will
# route thru the association called :papers on the Journal class.
#
Authorizations.configure do |config|
  #
  # System-level access
  #
  config.assignment_to(
    System,
    authorizes: Journal,
    via: :journals
  )

  config.assignment_to(
    System,
    authorizes: Paper,
    via: :papers
  )

  config.assignment_to(
    System,
    authorizes: Task,
    via: :tasks
  )

  config.assignment_to(
    System,
    authorizes: DiscussionTopic,
    via: :discussion_topics
  )

  #
  # Journal level access
  #
  config.assignment_to(
    Journal,
    authorizes: Paper,
    via: :papers
  )

  config.assignment_to(
    Journal,
    authorizes: Task,
    via: :tasks
  )

  config.assignment_to(
    Journal,
    authorizes: DiscussionTopic,
    via: :discussion_topics
  )


  #
  # Paper level access
  #
  config.assignment_to(
    Paper,
    authorizes: Task,
    via: :tasks
  )

  config.assignment_to(
    Paper,
    authorizes: DiscussionTopic,
    via: :discussion_topics
  )


  #
  # Task level access
  #
  config.assignment_to(
    Task,
    authorizes: Paper,
    via: :paper
  )

end
