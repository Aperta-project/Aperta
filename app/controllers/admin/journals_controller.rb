class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def index
    respond_with current_user.administered_journals, each_serializer: AdminJournalSerializer, root: 'admin_journals'
  end

  def update
    @journal = Journal.find(params[:id])

    if @journal.update(journal_params)
      render json: @journal, serializer: AdminJournalSerializer
    else
      respond_with @journal
    end
  end

  private

  def journal_params
    params.require(:journal).permit(:epub_cover)
  end
end
