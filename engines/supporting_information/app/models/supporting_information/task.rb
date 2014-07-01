module SupportingInformation
  class Task < ::Task
    title "Supporting Info"
    role "author"

    def file_access_details
      paper.files.map(&:access_details)
    end

    def assignees
      User.none
    end

    def active_model_serializer
      ::SupportingInformation::TaskSerializer
    end
  end
end
