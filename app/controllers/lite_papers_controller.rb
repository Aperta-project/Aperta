class LitePapersController < ApplicationController
  def index
    papers = Paper.where(id: paper_ids)
                  .get_all_by_page(page_number)
                  .all

    render json: papers, each_serializer: LitePaperSerializer
  end

  private

  def page_number
    (params[:page_number] || 2).to_i
  end

  def paper_ids
    current_user.submitted_papers.pluck(:id) | current_user.assigned_papers.pluck(:id)
  end
end
