class AssignmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    paper = Paper.find(params[:paper_id])
    authorize_action! paper: paper

    assignments = PaperRole.where(paper: paper)
    render json: assignments, each_serializer: AssignmentSerializer
  end

  def create
    paper = Paper.find(params[:assignment][:paper_id])
    authorize_action! paper: paper

    assignment = PaperRole.new(params.require(:assignment).permit(:role, :user_id, :paper_id))
    assignment.save!

    Activity.assignment_created!(assignment, user: current_user)

    render json: assignment, serializer: AssignmentSerializer
  end

  def destroy
    assignment = PaperRole.find(params[:id])
    authorize_action! paper: assignment.paper

    assignment.destroy!
    render json: assignment, serializer: AssignmentSerializer
  end
end
