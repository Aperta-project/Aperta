require 'rails_helper'

describe DiscussionTopicsPolicy do

  context "initializing without a paper (useful for #index? and event_stream#show?)" do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:discussion_topic) { FactoryGirl.create(:discussion_topic, paper: paper) }
    let(:policy) { DiscussionTopicsPolicy.new(current_user: user, resource: discussion_topic) }

    context "user with access" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        make_user_paper_editor(user, paper)
        discussion_topic.discussion_participants.create!(user: user)
      end

      specify { expect(policy.index?).to eq(true) }
      specify { expect(policy.create?).to eq(true) }
      specify { expect(policy.show?).to eq(true) }
    end

    context "user without access" do
      let(:user) { FactoryGirl.create(:user) }

      specify { expect(policy.index?).to eq(false) }
      specify { expect(policy.create?).to eq(false) }
      specify { expect(policy.show?).to eq(false) }
    end
  end

end
