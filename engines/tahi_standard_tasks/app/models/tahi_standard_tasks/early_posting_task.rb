module TahiStandardTasks
  class EarlyPostingTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Early Article Posting'
    DEFAULT_ROLE = 'author'
  end
end
