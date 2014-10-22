class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def collaborators
    users = UserSearch.collaborators(params[:paper_id])
    respond_with users, each_serializer: FilteredUsersSerializer, paper_id: params[:paper_id], root: false
  end

  def non_participants
    if params[:query].blank?
      respond_with [], root: false
    else
      users = UserSearch.non_participants(params[:task_id]).search do
        fulltext params[:query]
      end

      respond_with users.results, each_serializer: FilteredUsersSerializer, root: false
    end
  end

  def participants
    respond_with UserSearch.participants(params[:task_id]), each_serializer: FilteredUsersSerializer, root: false
  end

end
