module PlosAuthors
  class PlosAuthorsTask < Task
    title "Add Authors"
    role "author"

    include MetadataTask

    has_many :plos_authors, inverse_of: :plos_authors_task

    validate :validate_authors, if: :completed?

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

    private

    #TODO: refactor this
    def validate_authors
      self.errors[:plos_authors].clear # remove generic "is invalid" messages

      errors = plos_authors.each_with_object({}) do |plos_author, errors|
        if plos_author.invalid?
          errors[plos_author.id] = plos_author.errors
        end
      end

      if errors.any?
        self.errors.set(:plos_authors, errors)
        self.errors.add(:completed, "Please check the errors above.")
      end

      self.errors.empty?
    end
  end
end
