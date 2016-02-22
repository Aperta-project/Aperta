require 'rails_helper'

describe DiscussionTopic, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
  let(:topic_a) { paper.discussion_topics.create!(title: "Topic A") }

  describe ".including" do
    let(:topic_b) { paper.discussion_topics.create!(title: "Topic B") }
    let(:topic_c) { paper.discussion_topics.create!(title: "Topic C") }

    it "filters topics to participating users" do
      topic_a.discussion_participants.create!(user: user)
      topic_b.discussion_participants.create!(user: user)

      expect(DiscussionTopic.including(user).to_a).to contain_exactly(topic_a, topic_b)
    end
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
