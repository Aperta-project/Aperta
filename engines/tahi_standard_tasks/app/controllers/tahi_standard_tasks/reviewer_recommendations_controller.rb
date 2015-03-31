module TahiStandardTasks
  class ReviewerRecommendationsController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def create
      reviewer_recommendation = ReviewerRecommendation.create! reviewer_recommendation_params
      render json: reviewer_recommendation
    end

    private

    def reviewer_recommendation_params
      params.require(:reviewer_recommendation).permit(
        :reviewer_recommendations_task_id,
        :first_name,
        :middle_initial,
        :last_name,
        :email,
        :title,
        :department,
        :affiliation,
        :recommend_or_oppose)
    end
  end
end
