class ManuscriptManagerTemplatesController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def show
    requires_user_can(:administer, manuscript_manager_template.journal)
    respond_with manuscript_manager_template
  end

  def update
    requires_user_can(:administer, manuscript_manager_template.journal)
    template_form = ManuscriptManagerTemplateForm.new(new_template_params)
    template_form.update! manuscript_manager_template
    render json: manuscript_manager_template
  end

  def create
    requires_user_can(:administer, manuscript_manager_template.journal)
    template_form = ManuscriptManagerTemplateForm.new(new_template_params)
    respond_with template_form.create!
  end

  def destroy
    requires_user_can(:administer, manuscript_manager_template.journal)
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
    params.require(:manuscript_manager_template).permit(
      :paper_type,
      :journal_id,
      :uses_research_article_reviewer_report
    )
  end

  def new_template_params
    params.require(:manuscript_manager_template).permit(
      :paper_type,
      :journal_id,
      :uses_research_article_reviewer_report,
      phase_templates: [
        :name, :position, task_templates: [
          :title, :journal_task_type_id, :position
        ]
      ]
    ).tap do |whitelisted|
      whitelisted[:phase_templates].try(:each_index) do |i|
        pt = whitelisted[:phase_templates][i]
        pt[:task_templates].try(:each_index) do |j|
          value = params[:manuscript_manager_template][:phase_templates][i][:task_templates][j][:template]
          whitelisted[:phase_templates][i][:task_templates][j][:template] = value || []
        end
      end
    end
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
