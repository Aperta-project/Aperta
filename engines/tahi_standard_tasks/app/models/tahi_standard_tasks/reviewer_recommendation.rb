module TahiStandardTasks
  class ReviewerRecommendation < ActiveRecord::Base
    include Answerable
    include NestedQuestionable

    belongs_to :reviewer_recommendations_task, inverse_of: :reviewer_recommendations

    validates :first_name, :last_name, :email, presence: true, if: :task_completed?
    validates :email, format: { with: Devise.email_regexp, message: "needs to be a valid email address" }, if: :task_completed?

    alias_method :task, :reviewer_recommendations_task

    # useful for nested_questions to always have path to owner
    def paper
      reviewer_recommendations_task.paper
    end

    def task_completed?
      task && task.completed
    end
  end
end
