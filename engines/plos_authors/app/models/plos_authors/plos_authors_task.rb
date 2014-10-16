module PlosAuthors
  class PlosAuthorsTask < Task
    title "Add Authors"
    role "author"

    include MetadataTask

    has_many :plos_authors, inverse_of: :plos_authors_task

    def active_model_serializer
      TaskSerializer
    end
  end
end
