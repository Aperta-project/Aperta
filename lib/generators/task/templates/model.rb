module <%= engine_class_name %>
  class <%= class_name %>Task < Task
    register_task default_title: "<%= class_name %> Task", default_role: "author"

    def active_model_serializer
      TaskSerializer
    end
  end
end
