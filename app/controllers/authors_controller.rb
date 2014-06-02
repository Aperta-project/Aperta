class AuthorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    author = Author.create author_params
    respond_with author
  end

  def update
    author = Author.find(params[:id])
    author.update author_params
    respond_with author
  end

  def destroy
    author = Author.find(params[:id])
    author.destroy
    respond_with author
  end

  private
  def author_params
    params.require(:author).permit(
      :first_name,
      :last_name,
      :middle_initial,
      :email,
      :title,
      :department,
      :deceased,
      :corresponding,
      :affiliation,
      :secondary_affiliation,
      :author_group_id
    )
  end
end
