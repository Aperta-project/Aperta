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
        Activity.correspondence_edited! correspondence, user: current_user
      end
      render json: correspondence, status: :ok
    else
      respond_with correspondence, status: :unprocessable_entity
    end
  end

  # soft_delete is only available to external (manually added) correspondence,
  # where the additional_context column starts as nil from the email_logs create
  # step. Here we are guarding against other client updates, and explicitly only
  # updating the record's status and additional_context hash.
  def soft_delete
    correspondence = Correspondence.find(params[:id])
    if correspondence && correspondence.external?
      Correspondence.transaction do
        correspondence.update!(status: 'deleted', additional_context: { delete_reason: params[:reason] })
        Activity.correspondence_deleted! correspondence, user: current_user
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
