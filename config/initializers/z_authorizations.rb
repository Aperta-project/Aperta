# This file must load after the devise initializer

# This configuration defines how you get access to object based on your
# assignments
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
    authorizes: Task,
    via: :tasks
  )

  config.assignment_to(
    System,
    authorizes: Paper,
    via: :papers
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
