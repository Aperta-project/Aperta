module PlosAuthors
  class PlosAuthorsTask < Task

    register_task default_title: "Authors", default_role: "author"

    include MetadataTask

    has_many :plos_authors, inverse_of: :plos_authors_task

    validates_with AssociationValidator, association: :plos_authors, fail: :set_completion_error, if: :completed?
    validate :corresponding_plos_authors, if: :completed?

    def self.nested_questions
      questions = []

      questions << NestedQuestion.new(owner_id:1, owner_type: name, text: "This is a corresponding author", ident: "corresponding", value_type: "boolean")
      questions << NestedQuestion.new(owner_id:1, owner_type: name, text: "This person is deceased", ident: "deceased", value_type: "boolean")

      author_contributions = NestedQuestion.new owner_id:1, owner_type: name, text: "Author contributions", ident: "contributions", value_type: "question-set"
      author_contributions.children.build owner_id:1, owner_type: name, text: "Conceived and designed the experiments", ident: "contributed_experiments", value_type: "boolean", position: 1
      author_contributions.children.build owner_id:1, owner_type: name, text: "Performed the experiments", ident: "contributed_performing_experiments", value_type: "boolean", position: 2
      author_contributions.children.build owner_id:1, owner_type: name, text: "Analyzed the data", ident: "analyzed_data", value_type: "boolean", position: 3
      author_contributions.children.build owner_id:1, owner_type: name, text: "Contributed reagents/materials/analysis tools", ident: "contributed_tools", value_type: "boolean", position: 4
      author_contributions.children.build owner_id:1, owner_type: name, text: "Contributed to the writing of the manuscript", ident: "contributed_writing", value_type: "boolean", position: 5
      author_contributions.children.build owner_id:1, owner_type: name, text: "Other", ident: "contributed_other", value_type: "text", position: 6
      questions << author_contributions

      # TODO MOVE THIS OUT TO A SEED FILE
      questions.each do |q|
        unless NestedQuestion.where(owner_id:1, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

       NestedQuestion.where(owner_id:1, owner_type:name).all
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

    def nested_questions
      self.class.nested_questions
    end

    def set_completion_error
      self.errors.add(:completed, "Please fix validation errors above.")
    end

    def plos_authors_questions_and_answers
      authors = []
      self.plos_authors.each do |author|
        authors.push author.nested_questions_and_answers
      end
      authors
    end
  end
end
