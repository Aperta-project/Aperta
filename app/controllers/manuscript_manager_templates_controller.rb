class ManuscriptManagerTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def index
    respond_with journal.manuscript_manager_templates
  end

  def show
    respond_with journal.manuscript_manager_templates.find(params[:id])
  end

  def update
    template = journal.manuscript_manager_templates.find(params[:id])
    template.update_attributes!(template_params)
    respond_with template
  end

  def create
    template = journal.manuscript_manager_templates.create!(template_params)
    respond_with template
  end

  def destroy
    template = @journal.manuscript_manager_templates.find(params[:id])
    if @journal.manuscript_manager_templates.count > 1
      template.destroy
    else
      template.errors.add(:base, "Cannot destroy last template")
    end
    respond_with template
  end

  private

  def template_params
    tp = params.require(:manuscript_manager_template).permit([:paper_type, template: {phases: [:name, task_types: []]}])
    tp[:template] = {} unless tp[:template]
    tp
  end

  def enforce_policy
    authorize_action! journal: journal
  end

  def journal
    @journal ||= Journal.find(params[:journal_id])
  end
end
