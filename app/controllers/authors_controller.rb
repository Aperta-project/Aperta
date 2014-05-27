class AuthorsController < ApplicationController
  before_action :authenticate_user!

  def create
    author = Author.create author_params
    render json: author
  end

  def update
    author = Author.find(params[:id])
    author.update author_params
    render json: author
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
      :paper_id
    )
  end
end
