module TahiStandardTasks
  class RegisterDecisionController < ApplicationController

    def decide
      task = Task.find(params[:id])

      if task && task.paper.publishing_state == "submitted"
        task.complete_decision
        task.send_email
        head :ok
      else
        render json: { error: "Invalid Task and/or Paper" }
      end
    end

  end
end
