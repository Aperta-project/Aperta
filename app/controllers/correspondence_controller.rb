# Corresponcence Controller
#
# This is the same controller which handles internal and external
# correspondence. At the time it was authored, internal correspondence
# is referred to as "Corresponcence".
class CorrespondenceController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    paper = Paper.find params[:paper_id]
    requires_user_can :manage_workflow, paper
    render json: Correspondence.where(paper_id: params[:paper_id])
  end

  def create
    paper = Paper.find params[:external_correspondence][:paper_id]
    requires_user_can(:manage_workflow, paper)
    c = paper.correspondence.build correspondence_params
    c.recipients = params[:external_correspondence][:recipient]
    c.save!
    respond_with paper.correspondence.find(c.id), location: nil
  end

  private

  def correspondence_params
    params.require(:external_correspondence).permit(
      :cc,
      :bcc,
      :sender,
      # :recipient,
      :description,
      :subject,
      :body
      # :date
    )
  end
end
