module TahiStandardTasks
  class DataAvailabilityTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'Data Availability'
    DEFAULT_ROLE = 'author'
  end
end
