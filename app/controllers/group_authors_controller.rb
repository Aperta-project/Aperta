# Controller for authors that are not individuals; they are in the
# same list as authors, but have different data.
class GroupAuthorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :view, group_author.paper
    render json: group_author
  end

  def create
    requires_user_can :edit_authors,
      Paper.find_by_id_or_short_doi(group_author_params[:paper_id])
    group_author = GroupAuthor.new(group_author_params)
    group_author.save!
    group_author.author_list_item.move_to_bottom

    # render all group_authors, since position is controlled by acts_as_list
    render json: author_list_payload(group_author)
  end

  def update
    requires_user_can :edit_authors, group_author.paper
    group_author.update!(group_author_params)

    # render all group_authors, since position is controlled by acts_as_list
    render json: author_list_payload(group_author)
  end

  def destroy
    requires_user_can :edit_authors, group_author.paper
    group_author.destroy!

    # render all group_authors, since position is controlled by acts_as_list
    render json: author_list_payload(group_author)
  end

  private

  def group_author
    @group_author ||= GroupAuthor.includes(:author_list_item).find(params[:id])
  end

  def author_list_payload(group_author)
    serializer = PaperAuthorSerializer.new(group_author.paper, root: 'paper')
    hash = serializer.as_json
    hash.delete("paper")
    hash
  end

  def group_author_params
    params.require(:group_author).permit(
      :initial,
      :contact_first_name,
      :contact_middle_name,
      :contact_last_name,
      :contact_email,
      :position,
      :paper_id,
      :name,
      :card_id
    )
  end
end
