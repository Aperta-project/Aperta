module TahiStandardTasks
  # :nodoc:
  class UploadManuscriptTask < ::Task
    include ::MetadataTask

    DEFAULT_TITLE = 'Upload Manuscript'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
    def active_model_serializer
      TaskSerializer
    end

    def self.setup_new_revision(paper, phase)
      existing_uploading_manuscript_task = find_by(paper: paper)
      if existing_uploading_manuscript_task
        existing_uploading_manuscript_task
          .update(completed: false, phase: phase)
      else
        TaskFactory.create(self, paper: paper, phase: phase)
      end
    end
  end
end
