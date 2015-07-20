module TahiStandardTasks
  class RegisterDecisionController < ApplicationController

    def decide
      task = Task.find(params[:id])

      if task && task.paper.submitted?
        task.complete_decision
        task.send_email
        render json: {}, status: 200
      else
        render json: { error: "Invalid Task and/or Paper" }
      end
    end

  end
end
