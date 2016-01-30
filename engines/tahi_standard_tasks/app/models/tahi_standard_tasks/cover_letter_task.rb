module TahiStandardTasks
  class CoverLetterTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Cover Letter'
    DEFAULT_ROLE = 'author'

    def active_model_serializer
      TaskSerializer
    end
  end
end
