class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    respond_with Paper.all, each_serializer: PaperTrackerSerializer, root: 'papers'
  end
end
