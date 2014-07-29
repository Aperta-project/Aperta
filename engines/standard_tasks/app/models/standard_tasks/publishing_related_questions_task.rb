module StandardTasks
  class PublishingRelatedQuestionsTask < Task
    include MetadataTask

    title "Publishing Related Questions"
    role "author"

    def assignees
      User.none
    end
  end
end

