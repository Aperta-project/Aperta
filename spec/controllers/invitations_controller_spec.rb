require "rails_helper"

class TestTask < Task
  include Invitable

  DEFAULT_TITLE = 'Test Task'
  DEFAULT_ROLE = 'user'

  def invitation_rescinded(code:)
    true
  end
end

describe InvitationsController do
  let(:user) { invitee }
  let(:invitee) { FactoryGirl.create(:user) }
  let(:phase) { FactoryGirl.create(:phase) }
  let(:task) { FactoryGirl.create :invitable_task }

  describe "GET /invitations" do
    subject(:do_request) do
      get :index, format: :json
    end
    let!(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee) }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before { stub_sign_in user }
      it "returns required fields" do
        do_request
        expect(response.status).to eq(200)

        data = res_body.with_indifferent_access
        expect(data).to have_key(:invitations)
        invitation_json = data[:invitations][0]

        expect(invitation_json).to have_key(:title)
        expect(invitation_json).to have_key(:abstract)
        expect(invitation_json).to have_key(:invitation_type)
      end
    end
  end

  describe "GET /invitation/:id" do
    subject(:do_request) do
      get(:show, format: :json, id: invitation.id)
    end

    let!(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee) }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized' do
        before { stub_sign_in user }
      it "returns required fields" do
        do_request
        expect(response.status).to eq(200)

        data = res_body.with_indifferent_access
        expect(data).to have_key(:invitation)
        invitation_json = data[:invitation]

        expect(invitation_json).to have_key(:email)
        expect(invitation_json).to have_key(:state)
        expect(invitation_json).to have_key(:invitation_type)
      end

      it 'works if this is the invitee' do
        allow(user).to receive(:can?).with(:manage_invitations, task)
          .and_return(false)

        get(:show, format: :json, id: invitation.id)
        expect(response.status).to eq(200)
      end

      it 'works when the caller has manage_invitations permission' do
        allow(user).to receive(:can?).with(:manage_invitations, task)
          .and_return(true)
        new_user = FactoryGirl.create(:user)

        get(:show, format: :json, id: invitation.id, user: new_user)
        expect(response.status).to eq(200)
      end

      it 'returns a 403 when the caller can not manage invitations and is not the invitee' do
        new_user = FactoryGirl.build_stubbed(:user)
        stub_sign_in FactoryGirl.build_stubbed(:user)
        allow(new_user).to receive(:can?).and_return(false)

        get(:show, format: :json, id: invitation.id)
        expect(response.status).to eq(403)
      end
    end
  end

  describe "POST /invitations" do
    let(:invitation_body){
      "Hard to find a black cat in a dark room, especially if there is no cat."
    }

    subject(:do_request) do
      post(:create, {
        format: "json",
        invitation: {
          email: email_to_invite,
          task_id: task.id,
          body: invitation_body
        }
      })
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      let(:email_to_invite) { invitee.email }

      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task).and_return(true)
      end

      context 'and the invitee already exists' do
        before do
          expect(invitee.id).to be
        end

        it 'creates a invited invitation' do
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
      end

      context 'and the invitee does not exist in the system' do
        let(:email_to_invite) { 'custom-email@example.com' }
        it "creates an invitation for new user" do
          do_request

          expect(response.status).to eq 201

          data = res_body.with_indifferent_access
          invitation = Invitation.find(data[:invitation][:id])

          expect(invitation.invitee).to eq nil
          expect(invitation.email).to eq(email_to_invite)
          expect(invitation.code).to be_present
          expect(invitation.actor).to be_nil
          expect(invitation.state).to eq("invited")
        end
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

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "DELETE /invitations/:id" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

    context 'with manage_invitations permission' do
      before do
        allow(user).to receive(:can?).with(:manage_invitations, task)
          .and_return(true)
      end

      it "initiates the task callback" do
        expect_any_instance_of(InvitableTask).to receive(:invitation_rescinded).with(invitation)
        delete(:destroy, {
          format: "json",
          id: invitation.id
        })
      end

      context "Invitation with invitee" do
        let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task) }

        it "deletes the invitation queues up email job" do
          delete(:destroy,
                 format: "json",
                 id: invitation.id
                )
          expect(response.status).to eq 204
          expect(Invitation.exists?(id: invitation.id)).to eq(false)
        end
      end

      context "Invitation witout invitee" do
        let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: nil, email: "test@example.com", task: task) }

        it "deletes the invitation queues up email job" do
          expect(invitation.invitee).to be nil
          delete(:destroy,
                 format: "json",
                 id: invitation.id
                )
          expect(response.status).to eq 204
          expect(Invitation.exists?(id: invitation.id)).to eq(false)
        end
      end
    end

    context 'without manage_invitations permission' do
      before do
        allow(user).to receive(:can?)
          .with(:manage_invitations, task).and_return(false)
      end

      it 'returns a 403' do
        delete(:destroy,
               format: "json",
               id: invitation.id
              )

        expect(response.status).to eq(403)
      end
    end
  end

  context "transitioning state" do
    let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
    let(:task) { FactoryGirl.create(:paper_editor_task, paper: paper) }
    let(:invitation) do
      FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task)
    end

    describe "PUT /invitations/:id/accept" do
     it "gives access to the user as the editor" do
        put(:accept, format: "json", id: invitation.id)
        expect(response.status).to eq(204)
        invitation.reload
        expect(invitation.state).to eq("accepted")
        expect(invitation.actor).to eq(invitee)
        expect(task.paper.assigned_users).to include(invitee)
        expect(task.paper.academic_editors).to include(invitee)
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
