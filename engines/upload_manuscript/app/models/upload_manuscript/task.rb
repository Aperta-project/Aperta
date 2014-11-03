module UploadManuscript
  class Task < ::Task
    include ::MetadataTask

    register_task default_title: 'Upload Manuscript', default_role: 'author'

    def active_model_serializer
      UploadManuscript::TaskSerializer
    end
  end
end
