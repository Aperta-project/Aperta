require 'rails_helper'

describe 'InvitationFactory' do
  describe '#create' do
    subject(:invitation) { FactoryGirl.create :invitation }
    let(:decision) { invitation.decision }
    let(:paper) { invitation.paper }

    it 'creates an invitation' do
      is_expected.to be_an_instance_of Invitation
    end

    it 'is associated with a paper' do
      expect(paper).to be_an_instance_of Paper
    end

    it 'is associated with a decision' do
      expect(decision).to be_an_instance_of Decision
      expect(decision).to eq paper.draft_decision
    end
  end
end
