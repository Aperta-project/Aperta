require "rails_helper"

describe InvitationSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let!(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }
  let(:object_for_serializer) { invitation }

  let(:invitation_content) { deserialized_content.fetch(:invitation) }

  it "serializes successfully" do
    expect(deserialized_content).to match(hash_including(:invitation))
  end

  context "without an invitee" do
    subject(:invitation) { FactoryGirl.create :invitation, task: task, invitee: nil }

    it "serializes successfully" do
      expect(deserialized_content).to match(hash_including(users: []))
    end
  end

  it 'serializes :id' do
    expect(invitation_content).to match(hash_including(id: invitation.id))
  end

  it 'serializes :state' do
    expect(invitation_content).to match(hash_including(state: invitation.state))
  end

  it 'serializes :email' do
    expect(invitation_content).to match(hash_including(email: invitation.email))
  end

  it 'serializes :invitee_role' do
    expect(invitation_content).to match \
      hash_including(invitee_role: invitation.invitee_role)
  end

  it 'serializes :invitation_type' do
    expect(invitation_content).to match \
      hash_including(invitation_type: invitation.invitee_role.capitalize)
  end

  it 'serializes :created_at' do
    expect(invitation_content.fetch(:created_at)).to be
  end

  it 'serializes :updated_at' do
    expect(invitation_content.fetch(:created_at)).to be
  end
end
