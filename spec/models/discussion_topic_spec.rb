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

require 'rails_helper'

describe DiscussionTopic, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:topic_a) { paper.discussion_topics.create!(title: "Topic A") }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_discussion_participant_role
    )
  end

  describe "#has_participant?" do
    let(:user2) { FactoryGirl.create(:user) }

    it "checks if a user is a participant" do
      topic_a.discussion_participants.create!(user: user)

      expect(topic_a.has_participant?(user)).to be(true)
      expect(topic_a.has_participant?(user2)).to be(false)
    end
  end

  describe '#add_discussion_participant' do
    let(:discussion_participant) { FactoryGirl.build :discussion_participant, discussion_topic: topic_a }

    it 'creates assignment' do
      expect do
        topic_a.add_discussion_participant(discussion_participant)
      end.to change { topic_a.assignments.count }.by(1)
    end

    it 'creates discussion_participant' do
      expect do
        topic_a.add_discussion_participant(discussion_participant)
      end.to change { DiscussionParticipant.count }.by(1)
    end
  end

  describe '#remove_discussion_participant' do
    let(:discussion_participant) { FactoryGirl.build :discussion_participant, discussion_topic: topic_a }

    before { topic_a.add_discussion_participant(discussion_participant) }

    it 'destroys assignment' do
      expect do
        topic_a.remove_discussion_participant(discussion_participant)
      end.to change { topic_a.assignments.count }.by(-1)
    end

    it 'destroys discussion_participant' do
      expect do
        topic_a.remove_discussion_participant(discussion_participant)
      end.to change { DiscussionParticipant.count }.by(-1)
    end
  end
end
