module PlosAuthors
  class PlosAuthorsTask < Task
    title "Add Authors"
    role "author"

    include MetadataTask

    has_many :plos_authors, inverse_of: :plos_authors_task

    validate :validate_authors, if: :completed?

    def active_model_serializer
      TaskSerializer
    end

    private

    #TODO: refactor this
    def validate_authors
      valid_authors = true
      self.errors[:plos_authors].clear # remove generic "is invalid" messages
      plos_authors.each do |plos_author|
        if plos_author.invalid?
          self.errors.add(:plos_authors, plos_author.errors.to_h.merge(id: plos_author.id))
          valid_authors = false
        end
      end

      self.errors.add(:completed, "Please check the errors above.") unless valid_authors
      self.errors.empty?
    end
  end
end
