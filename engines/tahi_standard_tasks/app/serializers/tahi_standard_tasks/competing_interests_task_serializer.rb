module TahiStandardTasks
  class CompetingInterestsTaskSerializer < ::TaskSerializer
    has_many :nested_questions, embed: :ids, include: true
  end
end
