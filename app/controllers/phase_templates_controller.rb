class PhaseTemplatesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    phase_template = PhaseTemplate.create(phase_template_params)
    respond_with phase_template
  end

  private

  def phase_template_params
    params.require(:phase_template).permit(:name, :manuscript_manager_template_id)
  end
end
