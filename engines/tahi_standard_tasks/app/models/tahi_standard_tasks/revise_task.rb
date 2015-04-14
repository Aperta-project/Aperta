module TahiStandardTasks
  class ReviseTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    include MetadataTask
    include EventStreamNotifier

    register_task default_title: "Revise Task", default_role: "author"

    def active_model_serializer
      ReviseTaskSerializer
    end
  end
end
