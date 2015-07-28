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

  def admins
    render_selectable_users(:admins)
  end

  def reviewers
    render_selectable_users(:reviewers)
  end

  private

  def render_selectable_users(role)
    paper = Paper.find(params[:paper_id])
    journal_role_ids = paper.journal.send(role).pluck(:id)

    if params[:query]
      users = User.fuzzy_search(email: params[:query])
                  .where(id: journal_role_ids)
    else
      users = User.where(id: journal_role_ids)
    end

    respond_with filter_available_reviewers(users, paper), each_serializer: SelectableUserSerializer
  end

  def filter_available_reviewers(users, current_paper)
    # get the users without pending invitations
    users.reject do |user|
      user.invitations_from_latest_revision.select do |invitation|
        invitation.paper == current_paper && invitation.state == "invited"
      end.any?
    end
  end
end
