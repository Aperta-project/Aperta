module TahiStandardTasks
  class ReviewerRecommendation < ActiveRecord::Base
    include Answerable
    include ViewableModel

    belongs_to :reviewer_recommendations_task

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true

    alias_method :task, :reviewer_recommendations_task

    # NestedQuestionAnswersController will save the paper_id to newly created
    # answers if an answer's owner responds to :paper. This method is needed by
    # the NestedQuestionAnswersController#fetch_answer method, among others
    def paper
      reviewer_recommendations_task.paper
    end
  end
end
