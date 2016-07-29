module TahiStandardTasks
  class RegisterDecisionController < ::ApplicationController
    def decide
      task = Task.find(params[:id])
      requires_user_can :register_decision, task.paper

      if !task.paper.submitted?
        task.errors.add(:errors, "Paper is not submitted")
        fail ActiveRecord::RecordInvalid, task
      elsif !task.latest_decision_ready?
        render json: {
          errors: { 'errors': ['You must register a verdict first.'] }
        }, status: 422
      else
        decision = task.latest_decision
        task.complete_decision
        to_field = task.answer_for('register_decision_questions--to-field').value
        subject = task.answer_for('register_decision_questions--subject-field')
        task.send_email(to_field: to_field, subject_field: subject)
        Activity.decision_made! decision, user: current_user
        render json: decision, status: :created
      end
    end
  end
end
