module TahiStandardTasks
  class AuthorsTask < Task
    register_task default_title: "Authors", default_role: "author"

    include MetadataTask

    # TODO: reverse this relationship - authors_task belongs_to author?
    has_many :authors, inverse_of: :authors_task

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
