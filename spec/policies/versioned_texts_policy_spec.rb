require 'rails_helper'

describe VersionedTextsPolicy do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  # this will have been automagically created by setting the paper
  # body
  let(:versioned_text) { VersionedText.where(paper: paper).first }
  let(:policy) { VersionedTextsPolicy.new(current_user: user, resource: versioned_text) }

  describe "show?" do
    it "delegates to PapersPolicy" do
      papers_policy = policy.send :papers_policy
      expect(papers_policy).to receive(:show?).and_return(true)

      expect(policy.show?).to be(true)
    end
  end
end
