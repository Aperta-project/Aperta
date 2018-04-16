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

# Send a Notification to people mentioned in a forum reply
# rubocop:disable ClassAndModuleChildren
class DiscussionReply::Created::NotifyPeopleMentioned
  def self.call(_event_name, event_data)
    reply = event_data[:record]
    notifiable_users_mentioned = reply.user_mentions.notifiable_users_mentioned
    notifiable_users_mentioned.each do |mentionee|
      create_notification(reply, mentionee) if reply.discussion_topic.has_participant?(mentionee)
    end
  end

  def self.create_notification(reply, mentionee)
    reply.notifications.where({
      paper: reply.discussion_topic.paper,
      user: mentionee,
      parent_id: reply.discussion_topic.id,
      parent_type: 'DiscussionTopic'
    }).first_or_create!
  end
end
