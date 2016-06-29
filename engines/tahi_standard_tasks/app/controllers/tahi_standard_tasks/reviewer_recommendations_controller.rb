module TahiStandardTasks
  class ReviewerRecommendationsController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def create
      requires_user_can(:edit, reviewer_recommendation.task)
      reviewer_recommendation.save!
      render json: reviewer_recommendation, status: :created
    end

    def update
      requires_user_can(:edit, reviewer_recommendation.task)
      reviewer_recommendation.update!(reviewer_recommendation_params)
      render json: reviewer_recommendation
    end

    def destroy
      requires_user_can(:edit, reviewer_recommendation.task)
      reviewer_recommendation.destroy!
      head :no_content
    end

    private

    def reviewer_recommendation
      @reviewer_recommendation ||= begin
        if params[:id]
          ReviewerRecommendation.find(params[:id])
        else
          ReviewerRecommendation.new(reviewer_recommendation_params)
        end
      end
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
        :ringgold_id)
    end
  end
end
