module TahiStandardTasks
  class AuthorsTask < Task
    DEFAULT_TITLE = 'Authors'
    DEFAULT_ROLE = 'author'

    include MetadataTask

    has_many :authors, through: :author_list_items, source_type: "Author"
    has_many :author_list_items, foreign_key: :task_id

    validates_with AssociationValidator, association: :authors, fail: :set_completion_error, if: :completed?

    def active_model_serializer
      TahiStandardTasks::AuthorsTaskSerializer
    end

    private

    def set_completion_error
      self.errors.add(:completed, "Please fix validation errors above.")
    end
  end
end
