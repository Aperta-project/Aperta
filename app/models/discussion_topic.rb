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

class DiscussionTopic < ActiveRecord::Base
  include ViewableModel
  include EventStream::Notifiable

  belongs_to :paper, inverse_of: :discussion_topics

  has_many :discussion_participants, inverse_of: :discussion_topic, dependent: :destroy
  has_many :participants, through: :discussion_participants, source: :user, class_name: 'User'
  has_many :discussion_replies, inverse_of: :discussion_topic, dependent: :destroy
  has_many :notifications, as: :target
  has_many :assignments, as: :assigned_to
  has_one :journal, through: :paper

  validates_presence_of :title

  def has_participant?(user)
    participants.include? user
  end

  def add_discussion_participant(participant)
    discussion_participant = participant
    discussion_participant = DiscussionParticipant.new(user: participant) unless
      participant.is_a?(DiscussionParticipant)

    assignments.create(
      user: discussion_participant.user,
      role: journal.discussion_participant_role
    )

    discussion_participants.append(discussion_participant)
  end

  def add_discussion_participants_by_id(user_ids)
    user_ids.each do |id|
      user = User.find(id)
      add_discussion_participant(user)
    end
  end

  def remove_discussion_participant(discussion_participant)
    assignments.find_by(
      user: discussion_participant.user,
      role: journal.discussion_participant_role
    ).try(&:destroy)
    discussion_participant.destroy
  end
end
