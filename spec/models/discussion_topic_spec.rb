require 'rails_helper'

describe DiscussionTopic, type: :model do

  describe ".including" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:topic_a) { paper.discussion_topics.create!(title: "Topic A") }
    let(:topic_b) { paper.discussion_topics.create!(title: "Topic B") }
    let(:topic_c) { paper.discussion_topics.create!(title: "Topic C") }

    it "filters topics to participating users" do
      topic_a.discussion_participants.create!(user: user)
      topic_b.discussion_participants.create!(user: user)

      expect(DiscussionTopic.including(user).to_a).to contain_exactly(topic_a, topic_b)
    end
  end

  describe "#has_participant?" do
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:topic_a) { paper.discussion_topics.create!(title: "Topic A") }

    it "checks if a user is a participant" do
      topic_a.discussion_participants.create!(user: user)

      expect(topic_a.has_participant?(user)).to be(true)
      expect(topic_a.has_participant?(user2)).to be(false)
    end
  end
end
