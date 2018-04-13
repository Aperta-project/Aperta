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

class DiscussionReply < ActiveRecord::Base
  include ViewableModel
  include ActionView::Helpers::TextHelper
  include EventStream::Notifiable
  include CustomCastTypes

  attribute :body, HtmlString.new

  belongs_to :discussion_topic, inverse_of: :discussion_replies
  belongs_to :replier, inverse_of: :discussion_replies, class_name: 'User'
  has_many :notifications, as: :target

  before_create :process_at_mentions!

  delegate_view_permission_to :discussion_topic

  def process_at_mentions!
    self.body = user_mentions.decorated_mentions
  end

  def user_mentions
    @user_mentions ||=
      UserMentions.new(body, replier, permission_object: discussion_topic)
  end

  def sanitized_body
    formatted = simple_format(strip_tags(body))

    UserMentions
      .new(formatted, replier, permission_object: discussion_topic)
      .decorated_mentions
  end
end
