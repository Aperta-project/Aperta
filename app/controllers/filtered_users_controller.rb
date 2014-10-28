class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def users
    users = User.all.search do
      fulltext params[:query]
    end

    unless current_user.site_admin?
      users.results.reject! do |user|
        user.paper_roles.where(paper_id: params[:paper_id]).empty?
      end
    end
    respond_with users.results, each_serializer: FilteredUsersSerializer,
                                paper_id: params[:paper_id]
  end
end
