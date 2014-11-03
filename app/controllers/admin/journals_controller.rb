class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def index
    journals = current_user.administered_journals
      .includes(manuscript_manager_templates: {phase_templates: {task_templates: :journal_task_type}})

    respond_with journals, each_serializer: AdminJournalSerializer, root: 'admin_journals'
  end

  def show
    respond_to do |f|
      f.json { render json: Journal.find(params[:id]), serializer: AdminJournalSerializer, root: 'admin_journal' }
      f.html { render 'ember/index' , layout: 'ember'}
    end
  end

  def authorization
    head 204
  end

  def create
    respond_with Journal.create(journal_params), serializer: AdminJournalSerializer, root: 'admin_journal'
  end

  def update
    journal = Journal.find(params[:id])

    if journal.update(journal_params)
      render json: journal, serializer: AdminJournalSerializer
    else
      respond_with journal
    end
  end

  def upload_logo
    journal = DownloadLogo.call(Journal.find(params[:id]), params[:url])
    render json: journal, serializer: AdminJournalSerializer
  end

  def upload_epub_cover
    journal = DownloadEpubCover.call(Journal.find(params[:id]), params[:url])
    render json: journal, serializer: AdminJournalSerializer
  end

  private

  def journal_params
    params.require(:admin_journal).permit(:name, :description, :epub_cover, :epub_css, :pdf_css, :manuscript_css)
  end
end
