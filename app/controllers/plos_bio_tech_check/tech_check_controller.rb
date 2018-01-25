module PlosBioTechCheck
  class TechCheckController < ApplicationController
    before_action :authenticate_user!

    def send_email
      requires_user_can :edit, task
      NotifyAuthorOfChangesNeededService.new(
        task,
        submitted_by: current_user
      ).notify!
      render json: { success: true }
    end

    private

    def task
      @task ||= Task.find(params[:id])
    end
  end
end
