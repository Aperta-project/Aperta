class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    # show all papers that user is connected to across all journals
    papers = papers_submitted.where(journal_id: journal_ids)
    respond_with papers, each_serializer: PaperTrackerSerializer, root: 'papers'
  end

  private

  def journal_ids
    current_user.roles.pluck(:journal_id).uniq
  end

  def papers_submitted
    # All papers unless it has not yet been submitted for the first time
    Paper.where.not(publishing_state: :unsubmitted)
  end
end
