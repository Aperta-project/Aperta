module UploadManuscript
  class Task < ::Task
    include ::MetadataTask

    title "Upload Manuscript"
    role "author"

    def assignees
      []
    end

    def active_model_serializer
      UploadManuscript::TaskSerializer
    end
  end
end
