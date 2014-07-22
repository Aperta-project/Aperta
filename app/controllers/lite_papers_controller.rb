class LitePapersController < ApplicationController
  def index
    papers = Paper.get_all_by_page(params[:page_number].to_i)
    render json: papers, each_serializer: LitePaperSerializer
  end
end
