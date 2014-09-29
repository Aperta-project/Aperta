class LitePapersController < ApplicationController
  def index
    render json: papers, each_serializer: LitePaperSerializer
  end

  private

  def page_number
    (params[:page_number] || 2).to_i
  end

  def papers
    PaperRole.most_recent_for(current_user).page(page_number).map(&:paper)
  end
end
