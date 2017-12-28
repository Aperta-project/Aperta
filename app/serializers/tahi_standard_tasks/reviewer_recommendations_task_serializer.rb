module TahiStandardTasks
  class ReviewerRecommendationsTaskSerializer < ::TaskSerializer
    has_many :reviewer_recommendations, include: true, embed: :ids
  end
end
