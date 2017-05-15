module TahiStandardTasks
  class CompetingInterestsTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'Competing Interests'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
  end
end
