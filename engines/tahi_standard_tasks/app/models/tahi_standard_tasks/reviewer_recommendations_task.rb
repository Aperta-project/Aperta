module TahiStandardTasks
  class ReviewerRecommendationsTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    register_task default_title: "Reviewer Recommendations", default_role: "author"

    def active_model_serializer
      ReviewerRecommendationsTaskSerializer
    end
  end
end
