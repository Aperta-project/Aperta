module <%= @plugin_module %>
  class <%= class_name %>Task < Task

    register_task default_title: '<%= @task_name %>', default_role: 'author'

    def active_model_serializer
      <%= class_name %>TaskSerializer
    end

  end
end
