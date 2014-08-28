module <%= engine_class_name %>
  class <%= class_name %>Task < Task
    title "<%= class_name %> Task"
    role "author"

    def active_model_serializer
      TaskSerializer
    end
  end
end
