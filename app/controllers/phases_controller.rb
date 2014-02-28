class PhasesController < ApplicationController
  before_filter :authenticate_user!

  def create
    # add position for phases
    @phase = Phase.new(task_manager_id: params[:task_manager_id], name: "New Phase")
    if @phase.save
      render json: @phase.to_json
    end
  end
end
