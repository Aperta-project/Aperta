require 'spec_helper'

describe PaperFilter do
  describe "#paper" do
    let(:user) { author }
    let(:author) { create :user }
    let(:paper) { FactoryGirl.create :paper, user: author }
    subject(:policy) { PaperFilter.new(paper.id, user) }

    context "when the user is the author of the paper" do
      specify { expect(policy.paper).to eq paper }
    end

    context "when the user is not the author of the paper" do
      let(:user) { create :user }
      specify { expect(policy.paper).to be_nil }

      context "when the user is an admin" do
        before { user.update! admin: true }
        specify { expect(policy.paper).to eq paper }
      end

      context "when the user is a reviewer on that paper" do
        before { PaperRole.create! paper: paper, user: user, reviewer: true }
        specify { expect(policy.paper).to eq paper }
      end

      context "when the user is an editor on that paper" do
        before { PaperRole.create! paper: paper, user: user, editor: true }
        specify { expect(policy.paper).to eq paper }
      end
    end
  end
end
