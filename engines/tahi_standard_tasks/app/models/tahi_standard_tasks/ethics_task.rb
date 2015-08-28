module TahiStandardTasks
  class EthicsTask < Task
    include MetadataTask
    register_task default_title: "Ethics Statement", default_role: "author"
  end
end
