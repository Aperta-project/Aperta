module TahiStandardTasks
  class SupportingInformationTask < Task
    include MetadataTask

    DEFAULT_TITLE = 'Supporting Info'
    DEFAULT_ROLE = 'author'

    has_many :supporting_information_files,
             inverse_of: :supporting_information_task,
             foreign_key: :si_task_id

    validates_with AssociationValidator,
                   association: :supporting_information_files,
                   fail: :set_completion_error,
                   if: :completed?

    def file_access_details
      paper.files.map(&:access_details)
    end

    def active_model_serializer
      TaskSerializer
    end

    private

    def set_completion_error
      errors.add(:completed, 'Please fix validation errors above.')
    end
  end
end
