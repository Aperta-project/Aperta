module TahiUploadManuscript
  class UploadManuscriptTask < ::Task
    include ::MetadataTask

    register_task default_title: 'Upload Manuscript', default_role: 'author'

    def active_model_serializer
      TahiUploadManuscript::TaskSerializer
    end
  end
end
