module TahiStandardTasks
  class PublishingRelatedQuestionsTask < Task
    include MetadataTask

    DEFAULT_TITLE = 'Additional Information'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
  end
end
