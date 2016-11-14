module TahiStandardTasks
  class UploadManuscriptTask < ::Task
    include ::MetadataTask

    DEFAULT_TITLE = 'Upload Manuscript'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
    def active_model_serializer
      TaskSerializer
    end
  end
end
