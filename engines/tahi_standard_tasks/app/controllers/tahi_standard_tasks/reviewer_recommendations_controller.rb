module TahiStandardTasks
  class ReviewerRecommendationsController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def create
      task = Task.find(reviewer_recommendation_params[:reviewer_recommendations_task_id])
      reviewer_recommendation = task.reviewer_recommendations.new(reviewer_recommendation_params)
      #authorize_action!(reviewer_recommendation: reviewer_recommendation)
      reviewer_recommendation.save
      render json: reviewer_recommendation, status: :created
    end

    # def create
    #   task = Task.find(funder_params[:task_id])
    #   funder = task.funders.new(funder_params)
    #   authorize_action!(funder: funder)
    #   funder.save
    #   respond_with funder
    # end

    # def update
    #   funder = Funder.find(params[:id])
    #   authorize_action!(funder: funder)
    #   unmunge_empty_arrays!(:funder, [:author_ids])
    #   funder.update_attributes(funder_params)
    #   respond_with funder
    # end
    #
    # def destroy
    #   funder = Funder.find(params[:id])
    #   authorize_action!(funder: funder)
    #   funder.destroy
    #   respond_with funder
    # end

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
