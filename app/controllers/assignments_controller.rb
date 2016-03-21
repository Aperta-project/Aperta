# The AssignmentsController is the end-point responsible for managing
# assignments over HTTP.
class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    paper = Paper.find(params[:paper_id])
    requires_user_can(:assign_roles, paper)

    render(
      json: paper.assignments,
      each_serializer: AssignmentSerializer,
      root: :assignments
    )
  end

  def create
    paper = Paper.find(assignment_params[:paper_id])
    requires_user_can :assign_roles, paper

    role = paper.journal.roles.find(assignment_params[:role_id])
    target_user = User.find(assignment_params[:user_id])

    assignment = Assignment.where(
      assigned_to: paper,
      role: role,
      user: target_user
    ).first_or_create!

    Activity.assignment_created!(assignment, user: current_user)
    render json: assignment, serializer: AssignmentSerializer, root: :assignment
  end

  def destroy
    assignment = Assignment.find(params[:id])
    requires_user_can :assign_roles, assignment.assigned_to
    assignment.destroy
    render json: assignment, serializer: AssignmentSerializer, root: :assignment
  end

  private

  def assignment_params
    params.require(:assignment).permit(:paper_id, :user_id, :role_id)
  end
end
