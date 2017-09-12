module TahiStandardTasks
  # UploadManuscriptTask mostly exists for two reasons.
  # 1. It serves as a way to give permissions for users to upload a manuscript and
  #    a sourcefile for a given paper
  # 2. The setup_new_revision method ensures that an instance of this class exists
  #    in a specific phase
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
        # right now this will silently fail to add the task to the
        # paper if no card with the 'Upload Manuscript' CardTaskType exists
        # in the system
        card_task_type = CardTaskType.find_by(task_class: name) # could be nil
        new_card_version = Card.find_by(card_task_type: card_task_type).try(:latest_published_card_version)
        return unless new_card_version

        TaskFactory.create(self, paper: paper, phase: phase, card_version: new_card_version)
      end
    end

    # Overrides Task
    def self.create_journal_task_type?
      false
    end

    # UploadManuscriptTask renders card content.
    # This method is used in the TaskSerializer.
    def custom
      true
    end

    validate :check_sourcefile, if: -> { completed? && !paper.sourcefile? }

    # rubocop: disable Style/GuardClause
    def check_sourcefile
      if paper_should_have_sourcefile?
        errors.add(:sourcefile,
                   'Please upload your source file',
                   message: 'Please upload your source file')
      end
    end
    # rubocop: enable Style/GuardClause

    def paper_has_major_version?
      paper.major_version.present? && paper.major_version > 0
    end

    def paper_should_have_sourcefile?
      paper.file_type == 'pdf' && (paper.in_revision? || paper_has_major_version?)
    end
  end
end
