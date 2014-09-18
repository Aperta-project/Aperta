class LitePapersController < ApplicationController
  def index
    render json: papers, each_serializer: LitePaperSerializer
  end

  private

  def page_number
    (params[:page_number] || 2).to_i
  end

  def papers
    PaperRole.select("paper_id, max(created_at) as max_created").group(:paper_id).for_user(current_user).order("max_created DESC").page(page_number).map(&:paper)
  end
end
