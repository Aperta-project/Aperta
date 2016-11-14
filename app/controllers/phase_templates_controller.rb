class PhaseTemplatesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can(:administer, journal)
    phase_template.save
    respond_with phase_template
  end

  def update
    requires_user_can(:administer, journal)
    phase_template.update_attributes(phase_template_params)
    respond_with phase_template
  end

  def destroy
    requires_user_can(:administer, journal)
    phase_template.destroy
    respond_with phase_template
  end

  private

  def journal
    phase_template.journal
  end

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
end
