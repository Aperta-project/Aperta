module TahiStandardTasks
  class DataAvailabilityTask < ::Task
    include MetadataTask
    register_task default_title: "Data Availability", default_role: "author"
  end
end
