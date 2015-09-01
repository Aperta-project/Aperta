class ManuscriptManagerTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def show
    respond_with manuscript_manager_template
  end

  def update
    mmt_form = ManuscriptManagerTemplateForm.new(new_mmt_params)
    mmt_form.update_mmt manuscript_manager_template
    render json: manuscript_manager_template
  end

  def create
    mmt_form = ManuscriptManagerTemplateForm.new(new_mmt_params)
    respond_with mmt_form.create_mmt
  end

  def destroy
    journal = manuscript_manager_template.journal
    if journal.manuscript_manager_templates.count > 1
      manuscript_manager_template.destroy
    else
      manuscript_manager_template.errors.add(:base, "Cannot destroy last template")
    end

    respond_with manuscript_manager_template
  end

  private

  def template_params
    params.require(:manuscript_manager_template).permit(:paper_type, :journal_id)
  end

  def new_mmt_params
    params.require(:manuscript_manager_template).permit(:paper_type, :journal_id, phase_templates: [:name, :position, task_templates: [:title, :journal_task_type_id]])
  end

  def enforce_policy
    authorize_action! manuscript_manager_template: manuscript_manager_template
  end

  def manuscript_manager_template
    @mmt ||= if params[:id]
      ManuscriptManagerTemplate.find(params[:id])
    else
      ManuscriptManagerTemplate.new(template_params)
    end
  end

end
