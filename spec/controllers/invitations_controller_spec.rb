require "rails_helper"

describe InvitationsController do

  let(:invitee) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task) }

  before { sign_in(invitee) }

  describe "POST /invitations" do

    it "creates a pending invitation" do
      post(:create, {
        format: "json",
        invitation: {
          email: invitee.email,
          task_id: task.id
        }
      })
      expect(response.status).to eq(201)

      data = JSON.parse(response.body).with_indifferent_access
      invitation = Invitation.find(data[:invitation][:id])

      expect(invitation.invitee).to eq(invitee)
      expect(invitation.email).to eq(invitee.email)
      expect(invitation.code).to be_present
      expect(invitation.actor).to be_nil
      expect(invitation.state).to eq("pending")
    end
  end

  describe "PUT /invitations/:id" do

    let(:invitation) { FactoryGirl.create(:invitation, invitee: invitee) }

    it "can be accepted" do
      put(:update, {
        format: "json",
        id: invitation.id,
        invitation: {
          state: 'accepted'
        }
      })
      expect(response.status).to eq(200)

      data = JSON.parse(response.body).with_indifferent_access
      expect(data[:invitations][:paper_id]).to be_present

      invitation.reload
      expect(invitation.state).to eq("accepted")
      expect(invitation.actor).to eq(invitee)
    end

    it "can be rejected" do
      put(:update, {
        format: "json",
        id: invitation.id,
        invitation: {
          state: 'rejected'
        }
      })
      expect(response.status).to eq(204)
      invitation.reload
      expect(invitation.state).to eq("rejected")
      expect(invitation.actor).to eq(invitee)
    end

  end
end
