module TahiStandardTasks
  class ReportingGuidelinesTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'Reporting Guidelines'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
  end
end
