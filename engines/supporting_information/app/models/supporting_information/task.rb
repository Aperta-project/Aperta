module SupportingInformation
  class Task < ::Task
    include ::MetadataTask

    register_task default_title: 'Supporting Info', default_role: 'author'

    def file_access_details
      paper.files.map(&:access_details)
    end

    def active_model_serializer
      ::SupportingInformation::TaskSerializer
    end
  end
end
