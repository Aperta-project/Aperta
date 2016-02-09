module TahiStandardTasks
  class ReviseTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Revise Task'
    DEFAULT_ROLE = 'author'

    def active_model_serializer
      ReviseTaskSerializer
    end
  end
end
