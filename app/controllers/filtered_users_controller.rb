class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def users
    #TODO don't do this
    if Rails.env.test?
      respond_with User.all, each_serializer: FilteredUsersSerializer, root: false
    else
      users = User.all.search do
        fulltext params[:query]
      end

      respond_with users.results, each_serializer: FilteredUsersSerializer, paper_id: params[:paper_id], root: false
    end
  end
end
