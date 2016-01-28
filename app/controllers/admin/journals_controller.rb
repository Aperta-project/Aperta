class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def index
    journals = current_user.administered_journals do |journal_query|
      journal_query.includes(
        :journal_task_types,
        old_roles: :flows,
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
    j = Journal.where(id: journal.id).includes(:journal_task_types, old_roles: :flows, manuscript_manager_templates: { phase_templates: { task_templates: :journal_task_type } }).first!
    respond_with(j, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def authorization
    head 204
  end

  def create
    journal.save!
    respond_with(journal, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def update
    journal.update(journal_params)
    respond_with(journal, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def upload_logo
    journal_with_logo = DownloadLogo.call(journal, params[:url])
    respond_with(journal_with_logo) do |format|
      format.json { render json: journal_with_logo, serializer: AdminJournalSerializer, status: :ok }
    end
  end

  def upload_epub_cover
    journal_with_cover = DownloadEpubCover.call(journal, params[:url])
    respond_with(journal_with_cover) do |format|
      format.json { render json: journal_with_cover, serializer: AdminJournalSerializer, status: :ok }
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

  def enforce_policy
    authorize_action!(resource: journal)
  end

  def journal_params
    params.require(:admin_journal).permit(
      :description, :doi_journal_prefix,
      :doi_publisher_prefix, :epub_cover,
      :epub_css, :last_doi_issued,
      :manuscript_css, :name,
      :pdf_css
    )
  end
end
