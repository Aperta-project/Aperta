class PhasesController < ApplicationController
  before_filter :authenticate_user!
  rescue_from ActiveRecord::RecordInvalid, with: :render_errors

  def create
    render json: Phase.insert_or_update_positions(phase_params)
  end

  def update
    render json: Phase.insert_or_update_positions(phase_params)
  end

  private

  def render_errors(e)
    render status: 400, json: {errors: e.record.errors}
  end

  def phase_params
    params.required(:phase).permit(:id, :task_manager_id, :name, :position)
  end
end
