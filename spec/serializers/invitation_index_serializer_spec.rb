require "rails_helper"

describe InvitationIndexSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let!(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }
  let(:object_for_serializer) { invitation }

  let(:invitation_content) { deserialized_content.fetch(:invitation) }

  it "serializes successfully" do
    expect(deserialized_content).to match(hash_including(:invitation))
  end

  it 'serializes :id' do
    expect(invitation_content).to match(hash_including(id: invitation.id))
  end

  it 'serializes :state' do
    expect(invitation_content).to match(hash_including(state: invitation.state))
  end

  it 'serializes :title' do
    expect(invitation_content).to match(hash_including(title: invitation.paper.title))
  end

  it 'serializes :abstract' do
    expect(invitation_content).to match(hash_including(abstract: invitation.paper.abstract))
  end

  it 'serializes :email' do
    expect(invitation_content).to match(hash_including(email: invitation.email))
  end

  it 'serializes :information' do
    expect(invitation_content).to match \
      hash_including(information: invitation.information)
  end

  it 'serializes :invitee_id' do
    expect(invitation_content).to match \
      hash_including(invitee_id: invitation.invitee_id)
  end

  it 'serializes :invitee_role' do
    expect(invitation_content).to match \
      hash_including(invitee_role: invitation.invitee_role)
  end

  it 'embeds the :task id and type' do
    expect(invitation_content).to match \
      hash_including(
        task: { id: invitation.task.id, type: invitation.task.type }
      )
  end

  it 'serializes :created_at' do
    expect(invitation_content.fetch(:created_at)).to be
  end

  it 'serializes :updated_at' do
    expect(invitation_content.fetch(:created_at)).to be
  end
end
