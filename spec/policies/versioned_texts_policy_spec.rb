require 'rails_helper'

describe VersionedTextsPolicy do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:versioned_text) { FactoryGirl.create(:versioned_text, paper: paper) }
  let(:policy) { VersionedTextsPolicy.new(current_user: user, resource: versioned_text) }

  describe "show?" do
    it "delegates to PapersPolicy" do
      papers_policy = policy.send :papers_policy
      expect(papers_policy).to receive(:show?).and_return(true)

      expect(policy.show?).to be(true)
    end
  end
end
