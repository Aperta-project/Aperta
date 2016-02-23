# This file must load after the devise initializer

# This configuration defines how you get access to object based on your
# assignments
Authorizations.configure do |config|
  config.assignment_to(
    Paper,
    authorizes: Task,
    via: :tasks
  )

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
    Task,
    authorizes: Paper,
    via: :paper
  )

  config.assignment_to(
    Paper,
    authorizes: DiscussionTopic,
    via: :discussion_topics
  )

  config.assignment_to(
    Journal,
    authorizes: DiscussionTopic,
    via: :discussion_topics
  )
end
