class PhasesController < ApplicationController
  before_filter :authenticate_user!
  rescue_from ActiveRecord::RecordInvalid, with: :render_errors

  def create
    phase = Phase.insert_at_position(new_phase_params)
    render json: phase
  end

  def update
    phase = Phase.find params[:id]
    phase.update_attributes! update_phase_params
    render json: phase
  end

  private

  def render_errors(e)
    render status: 400, json: {errors: e.record.errors}
  end

  def new_phase_params
    params.required(:phase).permit(:task_manager_id, :name, :position)
  end

  def update_phase_params
    params.required(:phase).permit(:name)
  end

end
