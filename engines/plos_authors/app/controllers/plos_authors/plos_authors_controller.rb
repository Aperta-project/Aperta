module PlosAuthors
  class PlosAuthorsController < ApplicationController
    before_action :authenticate_user!
    respond_to :json

    def create
      plos_author = PlosAuthor.create(plos_author_params)
      render json: plos_authors_for(plos_author.paper)
    end

    def update
      plos_author.update(plos_author_params)
      render json: plos_authors_for(plos_author.paper)
    end

    def destroy
      plos_author.destroy
      render json: plos_authors_for(plos_author.paper)
    end


    private

    def plos_author
      @plos_author ||= PlosAuthor.find(params[:id])
    end

    def plos_authors_for(paper)
      PlosAuthor.for_paper(paper).order("authors.position")
    end

    def plos_author_params
      params.require(:plos_author).permit(
        :paper_id,
        :plos_authors_task_id,
        :first_name,
        :middle_initial,
        :last_name,
        :email,
        :title,
        :department,
        :affiliation,
        :secondary_affiliation,
        :deceased,
        :corresponding,
        :position
      )
    end
  end
end
