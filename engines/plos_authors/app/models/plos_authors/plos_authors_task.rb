module PlosAuthors
  class PlosAuthorsTask < Task
    include MetadataTask

    title "Add Authors"
    role "author"

    def active_model_serializer
      TaskSerializer
    end
  end
end
