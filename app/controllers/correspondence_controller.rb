# Handle Correspondence: both internal and external
class CorrespondenceController < ApplicationController
  before_action :authenticate_user!, :ensure_paper

  respond_to :json

  def index
    render json: @paper.correspondence
  end

  def create
    correspondence = @paper.correspondence.build correspondence_params
    correspondence.sent_at = params.dig(:correspondence, :date)
    if correspondence.save
      Activity.correspondence_created! correspondence, user: current_user
      render json: correspondence, status: :ok
    else
      respond_with correspondence, status: :unprocessable_entity
    end
  end

  def show
    correspondence = Correspondence.find(params[:id])
    render json: correspondence, status: :ok
  end

  def update
    correspondence = Correspondence.find(params[:id])
    if correspondence && correspondence.external?
      Correspondence.transaction do
        correspondence.sent_at = params.dig(:correspondence, :date)
        correspondence.update!(correspondence_params)
        if correspondence_params[:status] == 'deleted'
          Activity.correspondence_deleted! correspondence, user: current_user
        else
          Activity.correspondence_edited! correspondence, user: current_user
        end
      end
      render json: correspondence, status: :ok
    else
      respond_with correspondence, status: :unprocessable_entity
    end
  end

  private

  def correspondence_params
    params.require(:correspondence).permit(
      :cc,
      :bcc,
      :sender,
      :recipients,
      :description,
      :subject,
      :body,
      :external,
      :status,
      additional_context: [:delete_reason]
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
