class ManuscriptManagerTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def show
    respond_with manuscript_manager_template
  end

  def update
    manuscript_manager_template.update_attributes!(template_params)
    respond_with manuscript_manager_template
  end

  def create
    manuscript_manager_template.save
    respond_with manuscript_manager_template
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
