class PhaseTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    phase_template.save
    respond_with phase_template
  end

  def update
    phase_template.update_attributes(phase_template_params)
    respond_with phase_template
  end

  def destroy
    phase_template.destroy
    respond_with phase_template
  end

  private

  def phase_template_params
    params.require(:phase_template).permit(:name, :manuscript_manager_template_id, :position)
  end

  def phase_template
    @phase_template ||= if params[:id]
      PhaseTemplate.find(params[:id])
    else
      PhaseTemplate.new(phase_template_params)
    end
  end

  def enforce_policy
    authorize_action! phase_template: phase_template
  end
end
