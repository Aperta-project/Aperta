# Handle Correspondence: both internal and external
class CorrespondenceController < ApplicationController
  before_action :authenticate_user!, :ensure_paper

  respond_to :json

  def index
    render json: @paper.correspondence
  end

  def create
    correspondence = @paper.correspondence.build correspondence_params
    correspondence.sent_at = params.dig(:correspondence, :sent_at)
    if correspondence.save
      render json: correspondence, status: :ok
    else
      respond_with correspondence, status: :unprocessable_entity
    end
  end

  def show
    correspondence = Correspondence.find(params[:id])
    render json: correspondence, status: :ok
  end

  private

  def correspondence_params
    params.require(:correspondence).permit(
      :cc,
      :bcc,
      :sender,
      :recipients,
      :sent_at,
      :description,
      :subject,
      :body,
      :external
    )
  end

  def ensure_paper
    paper_id = params.dig(:correspondence, :paper_id) || params[:paper_id]
    if paper_id
      @paper = Paper.find paper_id
      requires_user_can :manage_workflow, @paper
    else
      render :not_found
    end
  end
end
