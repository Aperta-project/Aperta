# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
    discussion_topic.save!
    discussion_topic.add_discussion_participants_by_id(
      initial_discussion_participant_ids_param
    )
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

  def new_discussion_users
    requires_user_can :start_discussion, paper
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

  def initial_discussion_participant_ids_param
    params
      .require(:discussion_topic)
      .require(:initial_discussion_participant_ids)
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
