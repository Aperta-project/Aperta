class AuthorGroupsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    respond_with AuthorGroup.ordinalized_create(author_group_params)
  end

  def destroy
    author_group = AuthorGroup.find(params[:id])
    author_group.destroy
    respond_with author_group
  end

  private

  def author_group_params
    params.require(:author_group).permit(:paper_id)
  end
end
