module TahiStandardTasks
  class ReviewerRecommendationsController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def create
      task = Task.find(reviewer_recommendation_params[:reviewer_recommendations_task_id])
      reviewer_recommendation = task.reviewer_recommendations.new(reviewer_recommendation_params)
      reviewer_recommendation.save
      render json: reviewer_recommendation, status: :created
    end

    def update
      reviewer_recommendation = ReviewerRecommendation.find(params[:id])
      reviewer_recommendation.update!(reviewer_recommendation_params)
      render json: reviewer_recommendation
    end

    def destroy
      reviewer_recommendation = ReviewerRecommendation.find(params[:id])
      reviewer_recommendation.destroy!
      head :no_content
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
        :ringgold_id,
        :recommend_or_oppose,
        :reason)
    end
  end
end
