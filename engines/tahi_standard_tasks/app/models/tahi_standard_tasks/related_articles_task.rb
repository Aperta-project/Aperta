module TahiStandardTasks
  # The Related Articles task is used by editors to connect articles
  # which either refer to one another after publishing, or should be
  # published simultaneously.
  class RelatedArticlesTask < Task
    DEFAULT_TITLE = 'Related Articles'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    def active_model_serializer
      TahiStandardTasks::RelatedArticlesTaskSerializer
    end
  end
end
