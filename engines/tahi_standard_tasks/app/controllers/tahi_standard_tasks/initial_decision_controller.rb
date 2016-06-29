module TahiStandardTasks
  class InitialDecisionController < ::ApplicationController

    def create
      register_initial_decision
      create_blank_decision
      InitialDecisionMailer.delay.notify decision_id: initial_decision.id
      Activity.decision_made! initial_decision, user: current_user
      render json: {}, status: :created
    end

    private

    def register_initial_decision
      paper.public_send "#{initial_decision.verdict}!"
    end

    def create_blank_decision
      task.paper.decisions.create(notify_requester: true)
    end

    def task
      @task ||= Task.find(params[:id])
    end

    def initial_decision
      @initial_decision ||= task.initial_decision
    end
  end
end
