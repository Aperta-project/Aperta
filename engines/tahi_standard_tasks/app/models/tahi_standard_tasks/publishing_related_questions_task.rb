module TahiStandardTasks
  class PublishingRelatedQuestionsTask < Task
    include MetadataTask

    register_task default_title: 'Additional Information',
                  default_role: 'author'
  end
end
