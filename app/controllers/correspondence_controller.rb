class CorrespondenceController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
   render json: Correspondence.where(paper_id: params[:paper_id])
  end

end
