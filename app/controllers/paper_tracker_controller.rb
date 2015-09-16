class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    papers = current_user.assigned_papers.submitted
    respond_with papers, each_serializer: PaperTrackerSerializer, root: 'papers'
  end
end
