require "rails_helper"

class TestTask < Task
  include TaskTypeRegistration
  include Invitable
  register_task default_title: "Test Task", default_role: "user"
end

describe InvitationsController do

  let(:invitee) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task, type: "TestTask") }

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

  describe "DESTROY /invitations/:id" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

    it "rejects the invitation" do
      delete(:destroy, {
        format: "json",
        id: invitation.id
      })
      expect(response.status).to eq(204)
      invitation.reload
      expect(invitation.state).to eq("rejected")
      expect(invitation.actor).to eq(invitee)
      expect(Invitation.find_by id: invitation.id).to_not be_nil
    end
  end

  context "transitioning state" do
    let(:task) { FactoryGirl.create(:paper_editor_task) }
    let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

    describe "PUT /invitations/:id/accept" do
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
  end
end
