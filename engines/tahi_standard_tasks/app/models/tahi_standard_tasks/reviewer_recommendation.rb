module TahiStandardTasks
  class ReviewerRecommendation < ActiveRecord::Base
    include NestedQuestionable

    belongs_to :reviewer_recommendations_task

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
