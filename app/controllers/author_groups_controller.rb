class AuthorGroupsController < ApplicationController
  before_action :authenticate_user!

  def create
    render json: AuthorGroup.ordinalized_create(author_group_params)
  end

  def destroy
    author_group = AuthorGroup.find_by_id(params[:id])
    if author_group
      author_group.destroy
      head :ok
    else
      head :forbidden
    end
  end

  private
  def author_group_params
    params.require(:author_group).permit(:paper_id)
  end
end
