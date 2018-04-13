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

class CommentLookManager
  def self.sync_task(task)
    task.comments.map do |comment|
      sync_comment(comment)
    end
  end

  def self.sync_comment(comment)
    comment.transaction do
      comment.save!
      comment.notify_mentioned_people

      comment.task.participants.where.not(id: comment.commenter).each do |user|
        create_comment_look(user, comment)
      end
    end
  end

  def self.create_comment_look(user, comment)
    return unless user.present?
    return if comment.created_by?(user)

    participation = user.participations.find_by(assigned_to: comment.task)
    if participation && comment.created_at >= participation.created_at
      comment.comment_looks.where(user_id: user.id).first_or_create!
    end
  end
end
