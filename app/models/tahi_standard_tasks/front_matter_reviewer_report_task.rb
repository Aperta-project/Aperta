module TahiStandardTasks
  # The FrontMatterReviewerReportTask represents a different report
  # that a reviewer (user) can fill out. It provides different questions
  # than the generic ReviewerReportTask.  
  class FrontMatterReviewerReportTask < ReviewerReportTask
    DEFAULT_TITLE = 'Front Matter Reviewer Report'

    def active_model_serializer
      TahiStandardTasks::FrontMatterReviewerReportTaskSerializer
    end
  end
end
