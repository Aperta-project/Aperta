module TahiStandardTasks
  class CoverLetterTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Cover Letter'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze

    self.snapshottable = true

    def active_model_serializer
      TaskSerializer
    end
  end
end
