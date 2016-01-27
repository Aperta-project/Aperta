module TahiStandardTasks
  class ReviewerRecommendationsTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier
    include SubmissionTask

    register_task default_title: "Reviewer Candidates", default_role: "author"

    has_many :reviewer_recommendations,
      dependent: :destroy,
      foreign_key: 'reviewer_recommendations_task_id'

    def active_model_serializer
      ReviewerRecommendationsTaskSerializer
    end
  end
end
