require 'rails_helper'

describe InvitationSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let!(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }
  let(:object_for_serializer) { invitation }

  let(:invitation_content) { deserialized_content.fetch(:invitation) }

  it 'serializes successfully' do
    expect(deserialized_content).to match(hash_including(:invitation))

    expect(invitation_content).to match hash_including(
      decline_reason: invitation.decline_reason,
      email: invitation.email,
      id: invitation.id,
      invitee_role: invitation.invitee_role,
      reviewer_suggestions: invitation.reviewer_suggestions,
      state: invitation.state
    )

    expect(invitation_content.fetch(:created_at)).to be
    expect(invitation_content.fetch(:updated_at)).to be
  end

  context 'without an invitee' do
    subject(:invitation) { FactoryGirl.create :invitation, task: task, invitee: nil }

    it 'serializes successfully' do
      expect(deserialized_content).to match(hash_including(users: []))
    end
  end

end
