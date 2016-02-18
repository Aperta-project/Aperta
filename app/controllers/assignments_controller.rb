class AssignmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    paper = Paper.find(params[:paper_id])
    authorize_action! paper: paper

    assignments = PaperRole.includes(:user).where(paper: paper)
    render(
      json: assignments,
      each_serializer: PaperRoleSerializer,
      root: :assignments
    )
  end

  def create
    paper = Paper.find(params[:assignment][:paper_id])
    target_user = User.find(params[:assignment][:user_id])
    authorize_action! paper: paper

    # old assignment TODO: remove this!
    paper_role = PaperRole.new(assignment_params)
    paper_role.save!
    new_role_from_old = {
      'Editor' => paper.journal.handling_editor_role,
      'Admin' => paper.journal.staff_admin_role
    }

    if new_role_from_old[paper_role.old_role]
      # create new R&P assignment
      Assignment.where(
        user: target_user,
        role: new_role_from_old[paper_role.old_role],
        assigned_to: paper
      ).first_or_create!
    end

    Activity.assignment_created!(paper_role, user: current_user)
    render json: paper_role, serializer: PaperRoleSerializer, root: :assignment
  end

  def destroy
    paper_role = PaperRole.find(params[:id])
    authorize_action! paper: paper_role.paper

    paper = paper_role.paper
    new_role_from_old = {
      'Editor' => paper.journal.handling_editor_role,
      'Admin' => paper.journal.staff_admin_role
    }

    if new_role_from_old[paper_role.old_role]
      # destroy new R&P assignment
      Assignment.where(
        user: paper_role.user,
        role: new_role_from_old[paper_role.old_role],
        assigned_to: paper
      ).map(&:destroy!)
    end

    paper_role.destroy!
    render json: paper_role, serializer: PaperRoleSerializer, root: :assignment
  end

  private

  def assignment_params
    params.require(:assignment).permit(:old_role, :user_id, :paper_id)
  end
end
