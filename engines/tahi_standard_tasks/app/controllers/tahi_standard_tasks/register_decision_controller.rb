module TahiStandardTasks
  class RegisterDecisionController < ::ApplicationController
    def decide
      task = Task.find(params[:id])
      requires_user_can :register_decision, task.paper

      if !task || !task.paper.submitted?
        render json: {
          errors: { 'errors': ['Invalid Task and/or Paper'] }
        }, status: 422

      elsif not task.latest_decision_ready?
        render json: {
          errors: { 'errors': ['You must register a verdict first.'] }
        }, status: 422

      else
        decision = task.latest_decision
        task.complete_decision
        task.send_email
        Activity.decision_made! decision, user: current_user
        render json: {}, status: :created
      end
    end
  end
end
