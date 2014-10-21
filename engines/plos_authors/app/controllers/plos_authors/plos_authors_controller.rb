module PlosAuthors
  class PlosAuthorsController < ApplicationController
    before_action :authenticate_user!
    before_action :enforce_policy

    respond_to :json

    def create
      plos_author.save!
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
      @plos_author ||=
        if params[:id].present?
          PlosAuthor.find(params[:id])
        else
          PlosAuthor.new(plos_author_params)
        end
    end

    def plos_authors_for(paper)
      PlosAuthor.for_paper(paper).order("authors.position")
    end

    def enforce_policy
      authorize_action!(task: plos_author.plos_authors_task)
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
