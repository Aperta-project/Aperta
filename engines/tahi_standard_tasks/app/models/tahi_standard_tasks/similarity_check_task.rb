module TahiStandardTasks
  # The model class for the Similarity Check task, which is
  # used by SOMEONE for SOMETHING. FILL ME OUT PLEASE.
  class SimilarityCheckTask < Task
    DEFAULT_TITLE = 'Similarity Check'.freeze
    DEFAULT_ROLE_HINT = 'admin'.freeze

    # You should include MetadataTask if the task is required for
    # submission and should be visible to reviewers
    #
    # include MetadataTask
    #
    # You should include SubmissionTask if the task is required for
    # submission but should NOT be visible to reviewers.
    #
    # include SubmissionTask

    def active_model_serializer
      TahiStandardTasks::SimilarityCheckTaskSerializer
    end
  end
end
