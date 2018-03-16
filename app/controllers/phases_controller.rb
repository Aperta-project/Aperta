class PhasesController < ApplicationController
  before_action :authenticate_user!, :authorize_user
  respond_to :json

  def index
    respond_with paper.phases
  end

  def create
    respond_with paper.phases.create!(new_phase_params)
  end

  def update
    phase.update_attributes! update_phase_params
    respond_with phase
  end

  def show
    respond_with phase
  end

  def destroy
    if phase.tasks.empty? && phase.destroy
      render json: true
    else
      render :nothing => true, :status => 400
    end
  end

  private

  def new_phase_params
    params.require(:phase).permit(:name, :position)
  end

  def update_phase_params
    params.require(:phase).permit(:name)
  end

  def phase
    @phase ||= Phase.find_by(id: params[:id])
  end

  def paper
    # rubocop:disable Rails/DynamicFindBy
    @paper ||= Paper.find_by_id_or_short_doi(params[:paper_id] || params.dig(:phase, :paper_id))
    # rubocop:enable Rails/DynamicFindBy
  end

  def authorize_user
    requires_user_can(:manage_workflow, (params[:id] ? phase.paper : paper))
  end
end
