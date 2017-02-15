module TahiStandardTasks
  class ReviewerRecommendationsTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier
    include SubmissionTask

    DEFAULT_TITLE = 'Reviewer Candidates'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze

    self.snapshottable = true

    has_many :reviewer_recommendations,
      dependent: :destroy,
      foreign_key: 'reviewer_recommendations_task_id',
      inverse_of: :reviewer_recommendations_task

    validates_with AssociationValidator,
      association: :reviewer_recommendations,
      fail: :set_completion_error,
      if: :completed?

    def active_model_serializer
      ReviewerRecommendationsTaskSerializer
    end

    private

    def set_completion_error
      errors.add(:completed, "Please fix validation errors in candidates.")
    end
  end
end
