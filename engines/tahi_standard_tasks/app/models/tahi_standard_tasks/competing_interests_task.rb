module TahiStandardTasks
  class CompetingInterestsTask < ::Task
    include MetadataTask
    register_task default_title: "Competing Interests", default_role: "author"
  end
end
