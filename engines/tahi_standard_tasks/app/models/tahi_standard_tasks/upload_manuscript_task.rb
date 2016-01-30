module TahiStandardTasks
  class UploadManuscriptTask < ::Task
    include ::MetadataTask

    DEFAULT_TITLE = 'Upload Manuscript'
    DEFAULT_ROLE = 'author'
    def active_model_serializer
      TaskSerializer
    end
  end
end
