class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def users
    users = User.fuzzy_search params[:query]
    respond_with users, each_serializer: FilteredUserSerializer,
                        paper_id: params[:paper_id]
  end

  def editors
    render_selectable_users(:editors)
  end

  def academic_editors
    render_selectable_users(:academic_editors)
  end

  def admins
    render_selectable_users(:admins)
  end

  def uninvited_users
    users = User.fuzzy_search params[:query]
    paper = Paper.find(params[:paper_id])
    respond_with find_uninvited_users(users, paper), each_serializer: SelectableUserSerializer
  end

  private

  def render_selectable_users(role)
    paper = Paper.find(params[:paper_id])
    journal_role_ids = paper.journal.send(role).pluck(:id)

    users = User.where(id: journal_role_ids)
    users = users.fuzzy_search(params[:query]) if params[:query]

    respond_with find_uninvited_users(users, paper), each_serializer: SelectableUserSerializer
  end

  def find_uninvited_users(users, paper)
    Invitation.find_uninvited_users_for_paper(users, paper)
  end
end
