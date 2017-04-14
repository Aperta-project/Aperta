module TahiStandardTasks
  class CoverLetterTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Cover Letter'.freeze

    self.snapshottable = true

    def active_model_serializer
      TaskSerializer
    end
  end
end
