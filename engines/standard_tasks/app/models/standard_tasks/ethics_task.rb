module StandardTasks
  class EthicsTask < Task
    include MetadataTask

    title "Add Ethics Statement"
    role "author"

    def assignees
      User.none
    end
  end
end

