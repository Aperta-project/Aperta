class AuthorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    author = Author.create(author_params)
    render json: author.paper.authors, each_serializer: AuthorSerializer
  end

  def update
    author = Author.find(params[:id])
    author.update author_params
    render json: author.paper.authors, each_serializer: AuthorSerializer
  end

  def destroy
    author = Author.find(params[:id])
    author.destroy
    render json: author.paper.authors, each_serializer: AuthorSerializer
  end

  private

  def author_params
    params.require(:author).permit(
      :first_name,
      :last_name,
      :position,
      :paper_id,
      :position,
      :first_name,
      :middle_initial,
      :last_name,
      :email,
      :affiliation,
      :secondary_affiliation,
      :title,
      :corresponding,
      :deceased,
      :department,
      :contributions
    )
  end
end
