module TahiStandardTasks
  class PublishingRelatedQuestionsTask < Task
    include MetadataTask

    DEFAULT_TITLE = 'Additional Information'
    DEFAULT_ROLE = 'author'
  end
end
