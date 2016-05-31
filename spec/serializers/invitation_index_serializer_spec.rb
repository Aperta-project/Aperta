require 'rails_helper'

describe InvitationIndexSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let!(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }
  let(:object_for_serializer) { invitation }

  let(:invitation_content) { deserialized_content.fetch(:invitation) }

  it 'serializes successfully' do
    expect(deserialized_content).to match(hash_including(:invitation))

    expect(invitation_content).to match hash_including(
      id: invitation.id,
      state: invitation.state,
      title: invitation.paper.title,
      abstract: invitation.paper.abstract,
      email: invitation.email,
      information: invitation.information,
      invitee_id: invitation.invitee_id,
      invitee_role: invitation.invitee_role,
      task: { id: invitation.task.id, type: invitation.task.type }
    )

    expect(invitation_content.fetch(:created_at)).to be
    expect(invitation_content.fetch(:updated_at)).to be
  end
end
