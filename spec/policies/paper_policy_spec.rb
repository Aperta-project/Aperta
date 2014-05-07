require 'spec_helper'

describe PaperPolicy do
  describe "#paper" do
    let(:user) { author }
    let(:author) { create :user }
    let(:paper) { author.papers.create! short_title: 'On Policies', journal: Journal.create! }
    subject(:policy) { PaperPolicy.new(paper.id, user) }

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
