class TaskEligibleUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def academic_editors
    requires_user_can(:edit, task)

    eligible_users = EligibleUserService.eligible_users_for(
      paper: task.paper,
      role: task.paper.journal.academic_editor_role,
      matching: params[:query]
    )

    respond_with find_uninvited_users(eligible_users, task.paper), each_serializer: SelectableUserSerializer, root: :users
  end

  def admins
    requires_user_can(:edit, task)
    paper = Paper.find(params[:paper_id])
    journal_role_ids = paper.journal.send(old_role).pluck(:id)

    users = User.where(id: journal_role_ids)
    users = users.fuzzy_search(params[:query]) if params[:query]

    respond_with find_uninvited_users(users, paper), each_serializer: SelectableUserSerializer, root: :users
  end

  def uninvited_users
    requires_user_can(:edit, task)
    users = User.fuzzy_search params[:query]
    paper = Paper.find(params[:paper_id])
    respond_with find_uninvited_users(users, paper), each_serializer: SelectableUserSerializer, root: :users
  end

  private

  def find_uninvited_users(users, paper)
    Invitation.find_uninvited_users_for_paper(users, paper)
  end

  def task
    @task ||= Task.where(id: params[:task_id]).includes(:paper).first!
  end
end
