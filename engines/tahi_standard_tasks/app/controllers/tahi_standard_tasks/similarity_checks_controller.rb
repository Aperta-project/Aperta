module TahiStandardTasks
  #
  # add comments
  #
  class SimilarityChecksController < ::ApplicationController
    before_action :authenticate_user!

    respond_to :json

    def create
      requires_user_can(:perform_similarity_check, task.paper)
      # Make API call here
      render json: { test_create: true }
    end

    def show
      requires_user_can(:perform_similarity_check, similarity_check.paper)
      render json: { test_show: true }
    end

    private

    def delivery_params
      @delivery_params ||= params.require(:similarity_check).permit(:task_id)
    end

    def task
      Task.find(delivery_params[:task_id])
    end

    def similarity_check
      @similarity_check ||=
        if params[:id]
          SimilarityCheck.includes(:user, :paper, :task).find(params[:id])
        else
          SimilarityCheck.create!(
            paper: task.paper,
            task: task,
            user: current_user
          )
        end
    end
  end
end
