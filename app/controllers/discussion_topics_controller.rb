# In additiont to the normal CRUD actions, the +users+ action
# serves as a data source for the participants autocomplete.
#
class DiscussionTopicsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    topics = current_user
      .filter_authorized(:view, paper.discussion_topics)
      .objects
    respond_with topics, each_serializer: DiscussionTopicIndexSerializer
  end

  def show
    requires_user_can :view, discussion_topic
    respond_with discussion_topic
  end

  def create
    requires_user_can :start_discussion, discussion_topic.paper
    discussion_topic.discussion_participants.build(user: current_user)
    discussion_topic.save
    respond_with discussion_topic
  end

  def update
    requires_user_can :edit, discussion_topic
    discussion_topic.update(update_params)
    respond_with discussion_topic
  end

  def users
    requires_user_can :manage_participant, discussion_topic
    users = User.fuzzy_search params[:query]
    respond_with(
      users,
      each_serializer: SensitiveInformationUserSerializer,
      root: :users
    )
  end

  private

  def creation_params
    params.require(:discussion_topic).permit(:title, :paper_id)
  end

  def update_params
    params.require(:discussion_topic).permit(:title)
  end

  def discussion_topic
    @discussion_topic ||= begin
      if params[:id].present?
        DiscussionTopic.find(params[:id])
      elsif params[:discussion_topic].present?
        DiscussionTopic.new(creation_params)
      end
    end
  end

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params[:paper_id])
  end
end
