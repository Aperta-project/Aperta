class LitePapersController < ApplicationController
  def index
    render json: papers, each_serializer: LitePaperSerializer
  end

  private

  def page_number
    (params[:page_number] || 2).to_i
  end

  def papers
    current_user.assigned_papers.includes(:paper_roles).order("paper_roles.created_at DESC").page(page_number)
  end
end
