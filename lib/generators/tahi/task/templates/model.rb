module <%= @engine.camelcase %>
  # The model class for the <%= @task_title %> task, which is
  # used by SOMEONE for SOMETHING. FILL ME OUT PLEASE.
  class <%= name %> < Task
    DEFAULT_TITLE = '<%= @task_title %>'
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
      <%= @engine.camelcase %>::<%= name %>Serializer
    end
  end
end
