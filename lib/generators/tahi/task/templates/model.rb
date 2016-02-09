module <%= @plugin_module %>
  class <%= class_name %>Task < Task

    DEFAULT_TITLE = '<%= @task_name %>'
    DEFAULT_ROLE = 'author'

    def active_model_serializer
      <%= class_name %>TaskSerializer
    end

  end
end
