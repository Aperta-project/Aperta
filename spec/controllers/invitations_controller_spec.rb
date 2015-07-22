require "rails_helper"

class TestTask < Task
  include TaskTypeRegistration
  include Invitable
  register_task default_title: "Test Task", default_role: "user"

  def invitation_rescinded(paper_id:, invitee_id:)
    true
  end
end

class TestTasksPolicy < TasksPolicy; end

describe InvitationsController do

  let(:invitee) { FactoryGirl.create(:user) }
  let(:phase) { FactoryGirl.create(:phase) }
  let(:task) { FactoryGirl.create :invitable_task }

  before { sign_in(invitee) }

  describe "GET /invitations" do
    let!(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee) }

    it "returns required fields" do
      get(:index, format: :json)
      expect(response.status).to eq(200)

      data = res_body.with_indifferent_access

      expect(data).to have_key(:invitations)
      invitation_json = data[:invitations][0]

      expect(invitation_json).to have_key(:title)
      expect(invitation_json).to have_key(:abstract)
      expect(invitation_json).to have_key(:invitation_type)
    end
  end

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

      data = res_body.with_indifferent_access
      invitation = Invitation.find(data[:invitation][:id])

      expect(invitation.invitee).to eq(invitee)
      expect(invitation.email).to eq(invitee.email)
      expect(invitation.code).to be_present
      expect(invitation.actor).to be_nil
      expect(invitation.state).to eq("invited")
    end
  end

  describe "DELETE /invitations/:id", redis: true do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

    it "deletes the invitation queues up email job", redis: true do
      delete(:destroy, {
        format: "json",
        id: invitation.id
      })
      expect(response.status).to eq 204
      expect(Invitation.exists?(id: invitation.id)).to eq(false)
    end

    it "initiates the task callback" do
      expect_any_instance_of(InvitableTask).to receive(:invitation_rescinded).with(paper_id: task.paper.id, invitee_id: invitee.id)
      delete(:destroy, {
        format: "json",
        id: invitation.id
      })
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

    describe "PUT /invitations/:id/reject" do
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
end
