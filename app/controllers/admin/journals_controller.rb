class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    journals = current_user.administered_journals do |journal_query|
      journal_query.includes(
        :journal_task_types,
        :old_roles,
        manuscript_manager_templates: {
          phase_templates: {
            task_templates: :journal_task_type
          }
        }
      )
    end
    respond_with journals, each_serializer: AdminJournalSerializer, root: 'admin_journals'
  end

  def show
    j = Journal.where(id: journal.id).includes(:journal_task_types, :old_roles, manuscript_manager_templates: { phase_templates: { task_templates: :journal_task_type } }).first!
    requires_user_can(:administer, j)
    respond_with(j, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def authorization
    fail AuthorizationError unless current_user.administered_journals.any?
    head 204
  end

  def create
    requires_user_can(:administer, journal)
    journal.save!
    respond_with(journal, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def update
    requires_user_can(:administer, journal)
    journal.update(journal_params)
    respond_with(journal, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def upload_logo
    requires_user_can(:administer, journal)
    journal_with_logo = DownloadLogo.call(journal, params[:url])
    respond_with(journal_with_logo) do |format|
      format.json { render json: journal_with_logo, serializer: AdminJournalSerializer, status: :ok }
    end
  end

  private

  def journal
    @journal ||= begin
      if params[:id].present?
        Journal.find(params[:id])
      elsif params[:admin_journal].present?
        JournalFactory.create(journal_params)
      end
    end
  end

  def journal_params
    params.require(:admin_journal).permit(
      :description,
      :manuscript_css,
      :name,
      :pdf_css
    )
  end
end
