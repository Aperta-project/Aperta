class AuthorsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    author.save

    # render all authors, since position is controlled by acts_as_list
    render json: author.paper.authors, each_serializer: AuthorSerializer
  end

  def update
    author.update(author_params)

    # render all authors, since position is controlled by acts_as_list
    render json: author.paper.authors, each_serializer: AuthorSerializer
  end

  def destroy
    author.destroy

    # render all authors, since position is controlled by acts_as_list
    render json: author.paper.authors, each_serializer: AuthorSerializer
  end

  private

  def enforce_policy
    authorize_action!(author: author)
  end

  def author
    @author ||= begin
      if params[:id].present?
        Author.find(params[:id])
      else
        Author.new(author_params)
      end
    end
  end

  def author_params
    params.require(:author).permit(
      :authors_task_id,
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
      contributions: []
    )
  end
end
