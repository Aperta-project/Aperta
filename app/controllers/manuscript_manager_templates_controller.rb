class ManuscriptManagerTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!
  before_action :find_journal

  respond_to :json

  def index
    respond_with @journal.manuscript_manager_templates
  end

  def show
    respond_with @journal.manuscript_manager_templates.find(params[:id])
  end

  def update
     template = @journal.manuscript_manager_templates.find(params[:id])
     template.update_attributes!(template_params)
     respond_with template
  end

  def create
    template = @journal.manuscript_manager_templates.create!(template_params)
    respond_with template
  end

  private

  def template_params
    tp = params.require(:manuscript_manager_template).permit([:name, :paper_type, :template])
    tp[:template] = {} unless tp[:template]
    tp
  end

  def find_journal
    @journal = current_user.journals.find(params[:journal_id])
  end
end
