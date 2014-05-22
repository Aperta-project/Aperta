module UploadManuscript
  class Task < ::Task
    include ::MetadataTask

    title "Upload Manuscript"
    role "author"

    def assignees
      []
    end
  end
end
