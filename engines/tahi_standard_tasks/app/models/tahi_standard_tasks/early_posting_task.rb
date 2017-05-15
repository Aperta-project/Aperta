module TahiStandardTasks
  # Allows the author to opt in or out of considering their paper for early
  # posting
  class EarlyPostingTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Early Article Posting'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
  end
end
