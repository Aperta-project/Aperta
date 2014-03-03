class PhasesController < ApplicationController
  before_filter :authenticate_user!

  def create
    # add position for phases
    @phase = Phase.new(task_manager_id: params[:task_manager_id], name: "New Phase")
    if @phase.save
      render json: @phase.to_json
    end
  end

  def update
    flows = params[:flows].values
    ids = flows.map {|e| e[:id] }
    positions = flows.map {|e| e[:position] }

    @phases = Phase.where(task_manager_id: params[:task_manager_id])
    flows.each do |flow|
      phase = @phases.where(id: flow[:id]).first
      phase.update_attributes(position: flow[:position]) if phase
    end
    render json: true
  end
end
