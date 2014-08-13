module StandardTasks
  class AuthorsTask < Task
    has_many :authors, through: :paper
    before_validation :setup_associated_validations, if: :completed?

    include MetadataTask

    title "Add Authors"
    role "author"

    def setup_associated_validations
      authors.each do |a|
        a.mark_for_validation :first_name, :last_name, :title, :department, :affiliation, presence: true
        a.mark_for_validation :email, format: Devise.email_regexp
      end
    end

    def valid?(context=nil)
      super(context)
      valid_authors = true
      authors.each do |a|
        if a.invalid?
          self.errors.add(:authors, a.formatted_errors)
          valid_authors = false
        end
      end
      self.errors.add(:completed, "Please check the errors above.") unless valid_authors
      self.errors.empty?
    end

    def active_model_serializer
      TaskSerializer
    end

    def assignees
      User.none
    end
  end
end
