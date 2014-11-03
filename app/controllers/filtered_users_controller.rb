class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def users
    users = User.all.search do
      fulltext params[:query]
    end

    respond_with users.results, each_serializer: FilteredUserSerializer,
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
    journal = Journal.find(params[:journal_id])
    ids = journal.send(role).pluck(:id)
    users = User.search do
      with(:id, ids)
      fulltext params[:query]
    end
    respond_with users.results, each_serializer: SelectableUserSerializer
  end
end
