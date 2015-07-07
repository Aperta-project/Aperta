class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    journals = current_user.flow_managable_journals
    papers = Paper.where(journal: journals).submitted
    respond_with papers, each_serializer: LitePaperSerializer, root: 'papers'
  end
end
