module TahiStandardTasks
  class CompetingInterestsTaskSerializer < ::TaskSerializer
    has_many :questions, embed: :ids, include: true
  end
end
