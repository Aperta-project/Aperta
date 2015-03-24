module StandardTasks
  class EthicsTask < Task
    include MetadataTask
    register_task default_title: "Add Ethics Statement", default_role: "author"
  end
end

