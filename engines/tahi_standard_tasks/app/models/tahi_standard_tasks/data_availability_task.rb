module TahiStandardTasks
  class DataAvailabilityTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'Data Availability'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
  end
end
