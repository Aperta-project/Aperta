require "rails_helper"

describe InvitationsController do

  let(:invitee) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task) }

  before { sign_in(invitee) }

  describe "POST /invitations" do

    it "creates a invited invitation" do
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
      expect(invitation.state).to eq("invited")
    end
  end

  describe "PUT /invitations/:id/accept" do
    let(:task) { FactoryGirl.create(:paper_editor_task) }
    let(:invitation) { FactoryGirl.create(:invitation, invitee: invitee, task: task) }

    it "gives access to the user as the editor" do
      put(:accept, {
        format: "json",
        id: invitation.id
      })
      expect(response.status).to eq(204)
      invitation.reload
      expect(invitation.state).to eq("accepted")
      expect(invitation.actor).to eq(invitee)
      expect(task.paper.assigned_users).to include(invitee)
      expect(task.paper.editor).to eq(invitee)
    end
  end

  describe "PUT /invitations/:id/reject" do
    let(:task) { FactoryGirl.create(:paper_editor_task) }
    let(:invitation) { FactoryGirl.create(:invitation, invitee: invitee, task: task) }

    it "rejects the invitation" do
      put(:reject, {
        format: "json",
        id: invitation.id
      })
      expect(response.status).to eq(204)
      invitation.reload
      expect(invitation.state).to eq("rejected")
      expect(invitation.actor).to eq(invitee)
    end

  end
end
