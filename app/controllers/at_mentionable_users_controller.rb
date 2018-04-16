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

# A controller for retrieving lists of of at_mentionable users
class AtMentionableUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    users = User.who_can :be_at_mentioned, discussion_topic
    respond_with(
      users,
      each_serializer: SensitiveInformationUserSerializer,
      root: :users
    )
  end

  private

  # create a new instance of discussion_topic to determine permissions
  def discussion_topic
    @discussion_topic ||= DiscussionTopic.new(paper: paper)
  end

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(paper_id)
  end

  def paper_id
    params.require(:on_paper_id)
  end
end
