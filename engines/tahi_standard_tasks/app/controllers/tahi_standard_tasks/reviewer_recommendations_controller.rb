module TahiStandardTasks
  class ReviewerRecommendationsController < ::ApplicationController
    before_action :authenticate_user!
    before_action :enforce_policy
    respond_to :json

    def create
      reviewer_recommendation.save
      render json: reviewer_recommendation, status: :created
    end

    private

    def reviewer_recommendation
      @reviewer_recommendation ||= ReviewerRecommendation.new(reviewer_recommendation_params)
    end

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
        :ringgold_id,
        :recommend_or_oppose,
        :reason)
    end

    def enforce_policy
      authorize_action!(reviewer_recommendation: reviewer_recommendation)
    end
  end
end
