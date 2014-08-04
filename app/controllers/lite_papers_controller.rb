class LitePapersController < ApplicationController
  def index
    papers = Paper.where(id: paper_ids)
                  .paginate(page_number)
                  .all

    render json: papers, each_serializer: LitePaperSerializer
  end

  private

  def page_number
    (params[:page_number] || 2).to_i
  end

  def paper_ids
    current_user.assigned_papers.pluck :id
  end
end
