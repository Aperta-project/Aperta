module PlosAuthors
  class PlosAuthorsController < ApplicationController
    before_action :authenticate_user!
    before_action :enforce_policy

    respond_to :json

    def create
      plos_author.save!
      plos_author.created_activity! current_user
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
      authorize_action!(plos_author: plos_author)
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
        :ringgold_id,
        :secondary_affiliation,
        :secondary_ringgold_id,
        :deceased,
        :corresponding,
        :position,
        contributions: []
      ).tap do |whitelisted|
        whitelisted[:contributions] ||= []
      end
    end
  end
end
