module PlosAuthors
  class PlosAuthorsTask < Task

    register_task default_title: "Authors", default_role: "author"

    include MetadataTask

    has_many :plos_authors, inverse_of: :plos_authors_task

    validates_with AssociationValidator, association: :plos_authors, fail: :set_completion_error, if: :completed?
    validate :corresponding_plos_authors, if: :completed?

    def self.add_questions(task)
      task.nested_questions.build text: "This is a corresponding author", ident: "corresponding", value_type: "boolean"
      task.nested_questions.build text: "This person is deceased", ident: "deceased", value_type: "boolean"

      author_contributions = task.nested_questions.build text: "Author contributions", ident: "contributions", value_type: "question-set"
      author_contributions.children.build text: "Conceived and designed the experiments", ident: "contributed_experiments", value_type: "boolean"
      author_contributions.children.build text: "Performed the experiments", ident: "contributed_performing_experiments", value_type: "boolean"
      author_contributions.children.build text: "Analyzed the data", ident: "analyzed_data", value_type: "boolean"
      author_contributions.children.build text: "Contributed reagents/materials/analysis tools", ident: "contributed_tools", value_type: "boolean"
      author_contributions.children.build text: "Contributed to the writing of the manuscript", ident: "contributed_writing", value_type: "boolean"
      author_contributions.children.build text: "Other", ident: "contributed_other", value_type: "text"

      task
    end

    def active_model_serializer
      PlosAuthorsTaskSerializer
    end

    def convert_generic_authors!
      transaction do
        self.incomplete! if paper.authors.generic.any?
        paper.authors.generic.each do |author|
          PlosAuthor.create!(author: author, plos_authors_task: self)
        end
      end
    end

    def corresponding_plos_authors
      return true if plos_authors.where(corresponding: true).exists?
      self.errors.add(:corresponding, "You must have at least one corresponding author.")
    end

    def set_completion_error
      self.errors.add(:completed, "Please fix validation errors above.")
    end
  end
end
