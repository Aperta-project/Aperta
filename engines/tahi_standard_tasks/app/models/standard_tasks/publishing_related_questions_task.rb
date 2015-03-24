module StandardTasks
  class PublishingRelatedQuestionsTask < Task
    include MetadataTask

    register_task default_title: "Publishing Related Questions", default_role: "author"

  end
end

