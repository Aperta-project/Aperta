class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    journals = current_user.administered_journals do |journal_query|
      journal_query.includes(*relationships)
    end
    respond_with journals, each_serializer: AdminJournalSerializer, root: 'admin_journals'
  end

  def show
    requires_user_can(:administer, journal)
    respond_with(journal, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def authorization
    raise AuthorizationError unless current_user.administered_journals.any?
    head 204
  end

  def create
    raise AuthorizationError unless current_user.site_admin?
    @journal = JournalFactory.create(journal_params)
    process_pending_logo(params[:admin_journal][:logo_url])
    respond_with(journal, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  def update
    requires_user_can(:administer, journal)
    journal.update(journal_params)
    process_pending_logo(params[:admin_journal][:logo_url])
    respond_with(journal, serializer: AdminJournalSerializer, root: 'admin_journal')
  end

  private

  def journal
    @journal ||= Journal.includes(*relationships).find(params[:id])
  end

  def journal_params
    params.require(:admin_journal).permit(
      :description,
      :manuscript_css,
      :name,
      :pdf_css,
      :last_doi_issued,
      :doi_journal_prefix,
      :doi_publisher_prefix
    )
  end

  def process_pending_logo(url)
    return if url.blank? || !url.include?("/pending/")
    # logo is waiting to be processed in s3 pending bucket
    DownloadJournalLogoWorker.perform_async(journal.id, url)
  end

  def relationships
    [
      :journal_task_types,
      manuscript_manager_templates: {
        phase_templates: {
          task_templates: :journal_task_type
        }
      }
    ]
  end
end
