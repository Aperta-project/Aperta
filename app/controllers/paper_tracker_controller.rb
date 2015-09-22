class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    # show all papers that user is connected to across all journals
    papers = Paper.submitted.where(journal_id: journal_ids)
    respond_with papers, each_serializer: PaperTrackerSerializer, root: 'papers'
  end

  private

  def journal_ids
    current_user.roles.pluck(:journal_id).uniq
  end
end
