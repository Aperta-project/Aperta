module TahiStandardTasks
  class DataAvailabilityTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'Data Availability'.freeze
  end
end
