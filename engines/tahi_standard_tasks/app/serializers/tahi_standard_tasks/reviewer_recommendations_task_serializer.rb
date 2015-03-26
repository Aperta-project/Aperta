module TahiStandardTasks
  class ReviewerRecommendationsTaskSerializer < ::TaskSerializer
    attributes :institution_names

    def institution_names
      Institution.instance.names
    end
  end
end
