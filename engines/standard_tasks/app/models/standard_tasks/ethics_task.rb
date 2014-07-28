module StandardTasks
  class EthicsTask < Task
    include MetadataTask

    title "Add Ethics Statement"
    role "author"

    def active_model_serializer
      TaskSerializer
    end

    def assignees
      User.none
    end
  end
end

