class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def users
    users = User.search do
      fulltext params[:query]
    end

    respond_with users.results, each_serializer: FilteredUserSerializer,
                                paper_id: params[:paper_id]
  end

  def editors
    @users = paper.journal.editors
    filter_and_render
  end

  def admins
    @users = paper.journal.admins
    filter_and_render
  end

  def reviewers
    @users = paper.journal.reviewers
    filter_and_render
  end

  private

  def filter_and_render
    @users = @users.starts_with(params[:query]) if params[:query].present?
    respond_with @users, each_serializer: SelectableUserSerializer
  end

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end
end
