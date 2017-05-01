class AuthorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :view, author.paper
    render json: author
  end

  def create
    paper = Paper.find_by_id_or_short_doi(author_params[:paper_id])
    requires_user_can :edit_authors, paper
    author = Author.new(author_params)
    author.card_version = Author.latest_card_version
    author.save!
    author.author_list_item.move_to_bottom

    # render all authors, since position is controlled by acts_as_list
    render json: author_list_payload(author)
  end

  def update
    requires_user_can :edit_authors, author.paper
    author.update!(author_params)

    if current_user.can? :administer, author.paper.journal
      author.update_coauthor_state(author_coauthor_state, current_user.id)
    end

    # render all authors, since position is controlled by acts_as_list
    render json: author_list_payload(author)
  end

  def destroy
    requires_user_can :edit_authors, author.paper
    author.destroy!

    # render all authors, since position is controlled by acts_as_list
    render json: author_list_payload(author)
  end

  private

  def author
    @author ||= Author.includes(:author_list_item).find(params[:id])
  end

  def author_list_payload(author)
    serializer = PaperAuthorSerializer.new(author.paper, root: 'paper')
    hash = serializer.as_json
    hash.delete("paper")
    hash
  end

  def author_coauthor_state
    params.require(:author).permit(:co_author_state)[:co_author_state]
  end

  def author_params
    params.require(:author).permit(
      :author_initial,
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
      :department,
      :current_address_street,
      :current_address_street2,
      :current_address_city,
      :current_address_state,
      :current_address_country,
      :current_address_postal
    )
  end
end
