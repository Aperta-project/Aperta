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
    target_user = User.find(params[:assignment][:user_id])
    authorize_action! paper: paper

    # old assignment TODO: remove this!
    assignment = PaperRole.new(assignment_params)
    assignment.save!
    new_role_from_old = {
      'Editor' => paper.journal.roles.handling_editor,
      'Admin' => paper.journal.roles.staff_admin
    }
    # new assignment
    Assignment.where(
      user: target_user,
      role: new_role_from_old[assignment.old_role],
      assigned_to: paper
    ).first_or_create!

    Activity.assignment_created!(assignment, user: current_user)

    render json: assignment, serializer: PaperRoleSerializer, root: :assignment
  end

  def destroy
    assignment = PaperRole.find(params[:id])
    authorize_action! paper: assignment.paper

    paper = assignment.paper
    new_role_from_old = {
      'Editor' => paper.journal.roles.handling_editor,
      'Admin' => paper.journal.roles.staff_admin
    }

    Assignment.where(
      user: assignment.user,
      role: new_role_from_old[assignment.old_role],
      assigned_to: paper
    ).map(&:destroy!)

    assignment.destroy!
    render json: assignment, serializer: PaperRoleSerializer, root: :assignment
  end

  private

  def assignment_params
    params.require(:assignment).permit(:old_role, :user_id, :paper_id)
  end
end
