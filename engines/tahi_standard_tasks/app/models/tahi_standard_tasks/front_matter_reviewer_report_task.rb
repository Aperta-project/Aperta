module TahiStandardTasks
  # The model class for the Front Matter Reviewer Report task, which is
  # used by SOMEONE for SOMETHING. FILL ME OUT PLEASE.
  class FrontMatterReviewerReportTask < ReviewerReportTask
    DEFAULT_TITLE = 'Front Matter Reviewer Report'

    def active_model_serializer
      TahiStandardTasks::FrontMatterReviewerReportTaskSerializer
    end
  end
end
