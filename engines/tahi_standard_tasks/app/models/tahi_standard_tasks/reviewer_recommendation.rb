module TahiStandardTasks
  class ReviewerRecommendation < ActiveRecord::Base
    belongs_to :reviewer_recommendations_task
    validates :email, :recommend_or_oppose, presence: true
  end
end
