module TahiStandardTasks
  # The model class for the Front Matter Reviewer Report task, which is
  # used by SOMEONE for SOMETHING. FILL ME OUT PLEASE.
  class FrontMatterReviewerReportTask < Task
    DEFAULT_TITLE = 'Front Matter Reviewer Report'
    DEFAULT_ROLE = 'author'

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
      TahiStandardTasks::FrontMatterReviewerReportTaskSerializer
    end
  end
end
