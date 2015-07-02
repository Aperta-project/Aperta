class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    journals = current_user.flow_managable_journals
    papers = Paper.where(journal: journals, publishing_state: "submitted")
    respond_with papers, each_serializer: PaperTrackerSerializer, root: 'papers'
  end
end
