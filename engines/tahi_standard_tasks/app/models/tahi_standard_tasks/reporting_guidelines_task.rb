module TahiStandardTasks
  class ReportingGuidelinesTask < ::Task
    include MetadataTask
    register_task default_title: "Reporting Guidelines", default_role: "author"
  end
end
