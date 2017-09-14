# The FilteredUsersController returns user information for typeaheads.
# Unlike the TaskEligibleUsersController it's available for any
# logged-in user, and hence it doesn't return emails
class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def users
    users = User.fuzzy_search params[:query]
    respond_with users, each_serializer: FilteredUserSerializer,
                        paper_id: params[:paper_id],
                        root: :users
  end

  def assignable_users
    users = User.fuzzy_search params[:query]
    task = Task.find(params[:task_id])
    users = User.who_can('assign_others', task) & users
    respond_with users, each_serializer: FilteredUserSerializer,
                        root: :users
  end
end
