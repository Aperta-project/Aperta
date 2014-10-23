class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def collaborators
    users = UserSearch.collaborators(params[:paper_id])
    respond_with users, each_serializer: FilteredUsersSerializer, paper_id: params[:paper_id], root: false
  end

  def non_participants
    #solr fix for now
    if Rails.env.test?
      respond_with User.all, each_serializer: FilteredUsersSerializer, root: false
    else
      users = UserSearch.non_participants(params[:task_id]).search do
        fulltext params[:query]
      end

      respond_with users.results, each_serializer: FilteredUsersSerializer, root: false
    end
  end
end
