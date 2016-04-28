module TahiStandardTasks
  # The Related Articles task is used by editors to connect articles
  # which either refer to one another after publishing, or should be
  # published simultaneously.
  class RelatedArticlesTask < Task
    DEFAULT_TITLE = 'Related Articles'
    DEFAULT_ROLE = 'editor'

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
      TahiStandardTasks::RelatedArticlesTaskSerializer
    end
  end
end
