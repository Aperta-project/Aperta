class PhasesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @phase = Phase.insert_at_position(new_phase_params)
    respond_to do |format|
      format.json { render :show }
    end
  end

  def update
    @phase = Phase.find params[:id]
    @phase.update_attributes! update_phase_params
    respond_to do |format|
      format.json { render :show }
    end
  end

  def destroy
    @phase = Phase.find params[:id]
    if @phase.tasks.empty? && @phase.destroy
      render json: true
    else
      render :nothing => true, :status => 400
    end
  end

  private

  def new_phase_params
    params.require(:phase).permit(:task_manager_id, :name, :position)
  end

  def update_phase_params
    params.require(:phase).permit(:name)
  end
end
