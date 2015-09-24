module TahiStandardTasks
  class AuthorsTask < Task
    register_task default_title: "Authors", default_role: "author"

    include MetadataTask

    after_create :set_default_author

    has_many :authors, inverse_of: :authors_task

    validates_with AssociationValidator, association: :authors, fail: :set_completion_error, if: :completed?

    def active_model_serializer
      TahiStandardTasks::AuthorsTaskSerializer
    end

    private

    def set_completion_error
      self.errors.add(:completed, "Please fix validation errors above.")
    end

    def set_default_author
      author = participants.first
      current_affiliation = author.affiliations.by_date.first

      authors.create!(first_name: author.first_name,
                      last_name: author.last_name,
                      email: author.email,
                      paper: phase.paper).tap do |new_author|
                        if current_affiliation
                          new_author.affiliation = current_affiliation.name
                          new_author.department = current_affiliation.department
                          new_author.title = current_affiliation.title
                        end
      end
    end
  end
end
