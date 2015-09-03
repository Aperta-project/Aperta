require "rails_helper"

class TestTask < Task
  include TaskTypeRegistration
  include Invitable
  register_task default_title: "Test Task", default_role: "user"

  def invitation_rescinded(code:)
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
    let(:invitation_body){
      "Hard to find a black cat in a dark room, especially if there is no cat."
    }

    def do_request(invitation_params={})
      post(:create, {
        format: "json",
        invitation: {
          email: invitee.email,
          task_id: task.id,
          body: invitation_body
        }.merge(invitation_params)
      })
    end

    it "creates a invited invitation" do
      do_request

      expect(response.status).to eq(201)

      data = res_body.with_indifferent_access
      invitation = Invitation.find(data[:invitation][:id])

      expect(invitation.invitee).to eq(invitee)
      expect(invitation.email).to eq(invitee.email)
      expect(invitation.code).to be_present
      expect(invitation.actor).to be_nil
      expect(invitation.state).to eq("invited")
      expect(invitation.body).to eq(invitation_body)
    end

    it "creates an invitation for new user" do
      new_user_email = "custom-email@example.com"
      do_request(email: new_user_email)

      expect(response.status).to eq 201

      data = res_body.with_indifferent_access
      invitation = Invitation.find(data[:invitation][:id])

      expect(invitation.invitee).to eq nil
      expect(invitation.email).to eq(new_user_email)
      expect(invitation.code).to be_present
      expect(invitation.actor).to be_nil
      expect(invitation.state).to eq("invited")
    end

    it "creates an Activity" do
      expected_activity = {
        message: "#{invitee.full_name} was invited as #{task.invitee_role.capitalize}",
        feed_name: "workflow"
      }
      expect(Activity).to receive(:create).with hash_including(expected_activity)
      do_request
    end
  end

  describe "DELETE /invitations/:id", redis: true do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

    it "initiates the task callback" do
      expect_any_instance_of(InvitableTask).to receive(:invitation_rescinded).with(invitation)
      delete(:destroy, {
        format: "json",
        id: invitation.id
      })
    end

    context "Invitation with invitee" do
      let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

      it "deletes the invitation queues up email job", redis: true do
        delete(:destroy, {
          format: "json",
          id: invitation.id
        })
        expect(response.status).to eq 204
        expect(Invitation.exists?(id: invitation.id)).to eq(false)
      end
    end

    context "Invitation witout invitee" do
      let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: nil, email: "test@example.com", task: task) }

      it "deletes the invitation queues up email job", redis: true do
        expect(invitation.invitee).to be nil
        delete(:destroy, {
          format: "json",
          id: invitation.id
        })
        expect(response.status).to eq 204
        expect(Invitation.exists?(id: invitation.id)).to eq(false)
      end
    end
  end

  context "transitioning state" do
    let(:task) { FactoryGirl.create(:paper_editor_task) }
    let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

    describe "PUT /invitations/:id/accept" do
     it "gives access to the user as the editor" do
        put(:accept, format: "json", id: invitation.id)
        expect(response.status).to eq(204)
        invitation.reload
        expect(invitation.state).to eq("accepted")
        expect(invitation.actor).to eq(invitee)
        expect(task.paper.assigned_users).to include(invitee)
        expect(task.paper.editor).to eq(invitee)
      end

      it "creates an Activity" do
        expected_activity = {
          message: "#{invitee.full_name} accepted invitation as #{task.invitee_role.capitalize}",
          feed_name: "workflow"
        }
        expect(Activity).to receive(:create).with hash_including(expected_activity)
        put(:accept, format: "json", id: invitation.id)
      end
    end

    describe "PUT /invitations/:id/reject" do
      it "rejects the invitation" do
        put(:reject, format: "json", id: invitation.id)
        expect(response.status).to eq(204)
        invitation.reload
        expect(invitation.state).to eq("rejected")
        expect(invitation.actor).to eq(invitee)
      end

      it "creates an Activity" do
        expected_activity = {
          message: "#{invitee.full_name} declined invitation as #{task.invitee_role.capitalize}",
          feed_name: "workflow"
        }
        expect(Activity).to receive(:create).with hash_including(expected_activity)
        put(:reject, format: "json", id: invitation.id)
      end
    end
  end
end
