module PlosAuthors
  class PlosAuthorsController < ApplicationController
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
        :middle_initial,
        :email,
        :title,
        :department,
        :deceased,
        :corresponding,
        :affiliation,
        :secondary_affiliation,
        :position,
        :paper_id
      )
    end
  end
end
