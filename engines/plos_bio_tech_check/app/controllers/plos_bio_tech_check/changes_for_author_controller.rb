module PlosBioTechCheck
  # The ChangesForAuthorController is the end-point responsible for handling
  # interaction with the Changes For Author card.
  class ChangesForAuthorController < ApplicationController
    before_action :authenticate_user!

    def submit_tech_check
      requires_user_can :edit, task

      if task.submit_tech_check!(submitted_by: current_user)
        render json: task.paper
      else
        render json: task.paper, status: 422
      end
    end

    private

    def task
      @task ||= ChangesForAuthorTask.find(params[:id])
    end
  end
end
