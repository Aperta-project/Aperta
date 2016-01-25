class AssignmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    paper = Paper.find(params[:paper_id])
    authorize_action! paper: paper

    assignments = PaperRole.includes(:user).where(paper: paper)
    render json: assignments, each_serializer: PaperRoleSerializer, root: :assignments
  end

  def create
    paper = Paper.find(params[:assignment][:paper_id])
    authorize_action! paper: paper

    assignment = PaperRole.new(params.require(:assignment).permit(:old_role, :user_id, :paper_id))
    assignment.save!

    Activity.assignment_created!(assignment, user: current_user)

    render json: assignment, serializer: PaperRoleSerializer, root: :assignment
  end

  def destroy
    assignment = PaperRole.find(params[:id])
    authorize_action! paper: assignment.paper

    assignment.destroy!
    render json: assignment, serializer: PaperRoleSerializer, root: :assignment
  end
end
