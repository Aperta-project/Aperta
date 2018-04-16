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

class DiscussionParticipantsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can :manage_participant, discussion_topic
    discussion_topic.add_discussion_participant(discussion_participant)
    respond_with discussion_participant
  end

  def destroy
    requires_user_can :manage_participant, discussion_topic
    discussion_topic.remove_discussion_participant(discussion_participant)
    respond_with discussion_participant
  end

  def show
    requires_user_can :view, discussion_topic
    respond_with discussion_participant
  end

  private

  def creation_params
    params.require(:discussion_participant).permit(
      :discussion_topic_id,
      :user_id
    )
  end

  def discussion_participant
    @discussion_participant ||= begin
      if params[:id].present?
        DiscussionParticipant.find(params[:id])
      elsif params[:discussion_participant].present?
        DiscussionParticipant.new(creation_params)
      end
    end
  end

  def discussion_topic
    discussion_participant.discussion_topic
  end
end
