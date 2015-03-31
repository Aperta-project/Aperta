module TahiStandardTasks
  class ReviewerRecommendationsTaskSerializer < ::TaskSerializer
    attributes :institution_names
    has_many :reviewer_recommendations, include: true, embed: :id

    def institution_names
      Institution.instance.names
    end
  end
end
