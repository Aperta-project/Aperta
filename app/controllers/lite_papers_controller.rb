class LitePapersController < ApplicationController
  def index
    papers = current_user.assigned_papers.includes(:paper_roles).paginate(page_number)
    render json: papers, each_serializer: LitePaperSerializer
  end

  private

  def page_number
    (params[:page_number] || 2).to_i
  end
end
