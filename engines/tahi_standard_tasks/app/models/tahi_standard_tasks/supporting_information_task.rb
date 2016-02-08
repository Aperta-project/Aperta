module TahiStandardTasks
  class SupportingInformationTask < Task
    include MetadataTask

    DEFAULT_TITLE = 'Supporting Info'
    DEFAULT_ROLE = 'author'

    def file_access_details
      paper.files.map(&:access_details)
    end

    def active_model_serializer
      TaskSerializer
    end
  end
end
