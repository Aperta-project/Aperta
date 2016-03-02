module TahiStandardTasks
  class RegisterDecisionController < ApplicationController
    def decide
      task = Task.find(params[:id])

      if !task || !task.paper.submitted?
        render json: { error: "Invalid Task and/or Paper" }

      elsif not task.latest_decision_ready?
        render json: { error: "You must register a verdict, first" }, status: 422

      else
        requires_user_can :register_decision, task.paper
        decision = task.latest_decision
        task.complete_decision
        task.send_email
        Activity.decision_made! decision, user: current_user
        render json: {}, status: :created
      end
    end
  end
end
