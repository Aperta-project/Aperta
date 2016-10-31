require "rails_helper"

class TestTask < Task
  include Invitable

  DEFAULT_TITLE = 'Test Task'
  DEFAULT_ROLE = 'user'

  def invitation_rescinded(*)
    true
  end
end

describe InvitationsController do
  let(:user) { invitee }
  let(:invitee) { FactoryGirl.create(:user) }
  let(:phase) { FactoryGirl.create(:phase) }
  let(:task) { FactoryGirl.create :paper_editor_task }
  let!(:queue) { FactoryGirl.create(:invite_queue, task: task) }

  describe 'GET /invitations' do
    subject(:do_request) { get :index, format: :json }
    let!(:invitation) do
      FactoryGirl.create(:invitation, :invited, invitee: invitee)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before { stub_sign_in user }

      it 'returns required fields' do
        do_request
        expect(response.status).to eq(200)

        data = res_body.with_indifferent_access
        expect(data).to have_key(:invitations)
        invitation_json = data[:invitations][0]

        expect(invitation_json).to have_key(:title)
        expect(invitation_json).to have_key(:abstract)
        expect(invitation_json).to have_key(:invitee_role)
      end
    end
  end

  describe 'GET /invitation/:id' do
    subject(:do_request) { get(:show, format: :json, id: invitation.id) }

    let!(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee) }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized' do
      before { stub_sign_in user }
      it 'returns required fields' do
        do_request
        expect(response.status).to eq(200)

        data = res_body.with_indifferent_access
        expect(data).to have_key(:invitation)
        invitation_json = data[:invitation]

        expect(invitation_json).to have_key(:email)
        expect(invitation_json).to have_key(:state)
        expect(invitation_json).to have_key(:invitee_role)
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

  describe 'POST /invitations' do
    subject(:do_request) do
      post(
        :create,
        format: 'json',
        invitation: {
          email: email_to_invite,
          task_id: task.id,
          body: invitation_body,
        })
    end

    let(:email_to_invite) { invitee.email }
    let(:invitation_body) do
      'Hard to find a black cat in a dark room, especially if there is no cat.'
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task).and_return(true)
      end

      context 'with an email matching an existing user' do
        it 'creates a pending invitation for that user' do
          do_request
          expect(response.status).to eq(200)

          data = res_body.with_indifferent_access
          invitation = Invitation.find(data[:invitations][0][:id])

          expect(invitation.state).to eq('pending')
          expect(invitation.invitee).to eq(invitee)
          expect(invitation.email).to eq(invitee.email)
        end
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

  describe 'PUT /invitations/:id/send_invite' do
    let!(:invitation) do
      FactoryGirl.create(
        :invitation,
        state: 'pending',
        invitee: invitee,
        task: task
      )
    end
    subject(:do_request) do
      post(
        :send_invite,
        format: 'json',
        id: invitation.to_param)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'the user is signed in' do
      before do
        stub_sign_in user
      end

      context "when the user does not have access" do
        it { is_expected.to responds_with(403) }
      end

      context "when the user has access" do
        before do
          allow(user).to receive(:can?).with(:manage_invitations, task)
            .and_return(true)
        end

        it 'sends the invitation' do
          do_request
          data = res_body.with_indifferent_access
          saved_invitation = Invitation.find(data[:invitation][:id])
          expect(saved_invitation.state).to eq('invited')
        end

        it 'creates an activity' do
          expected_activity = {
            message: "#{invitee.full_name} was invited as #{task.invitee_role.capitalize}",
            feed_name: "workflow"
          }
          expect(Activity).to receive(:create).with hash_including(expected_activity)
          do_request
        end
      end
    end
  end

  describe "PUT /invitations/:id/rescind" do
    subject(:do_request) do
      put(
        :rescind,
        format: "json",
        id: invitation.to_param)
    end

    let(:invitation) do
      FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task)
    end

    it_behaves_like 'an unauthenticated json request'

    context "when the user has access" do
      let!(:invitation) do
        FactoryGirl.create(
          :invitation,
          :invited,
          invitee: invitee,
          task: task
        )
      end

      before do
        stub_sign_in user
        allow(user).to receive(:can?).with(:manage_invitations, task)
          .and_return(true)
      end

      context "Invitation with invitee" do
        it "changes invitation state to rescinded" do
          do_request
          expect(invitation.reload.state).to eq('rescinded')
        end

        it { is_expected.to responds_with(200) }
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task).and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  context "transitioning state" do
    let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
    let(:task) { FactoryGirl.create(:paper_editor_task, paper: paper) }
    let(:invitation) do
      FactoryGirl.create(:invitation, :invited, invitee: invitee, task: task)
    end

    describe "PUT /invitations/:id/accept" do
      subject(:do_request) { put(:accept, format: 'json', id: invitation.id) }

      it_behaves_like 'an unauthenticated json request'

      context 'when the user is authenticated' do
        before do
          stub_sign_in user
        end

        it "gives access to the user as an academic editor" do
          do_request
          expect(response.status).to eq(200)
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
          do_request
        end
      end

      context 'when the user is invitee' do
        before do
          stub_sign_in FactoryGirl.create(:user)
        end

        it 'renders status 403' do
          do_request
          expect(response.status).to eq 403
        end
      end
    end

    describe "PUT /invitations/:id/decline" do
      subject(:do_request) do
        put(
          :decline,
          id: invitation.to_param,
          format: :json,
          invitation: {
            decline_reason: 'This is my decline reason',
            reviewer_suggestions: 'Added reviewer suggesions' }
        )
      end

      it_behaves_like 'an unauthenticated json request'

      context 'when the user is authenticated' do
        before do
          stub_sign_in user
        end

        it 'declines the invitation' do
          do_request
          invitation.reload
          expect(invitation.state).to eq('declined')
          expect(invitation.actor).to eq(invitee)
          expect(invitation.decline_reason).to eq('This is my decline reason')
          expect(invitation.reviewer_suggestions).to eq('Added reviewer suggesions')
        end

        it 'creates an Activity' do
          expected_activity = {
            message: "#{invitee.full_name} declined invitation as #{task.invitee_role.capitalize}",
            feed_name: 'workflow'
          }
          expect(Activity).to receive(:create).with hash_including(expected_activity)
          do_request
        end

        it { is_expected.to responds_with(200) }
      end

      context 'when the user is invitee' do
        before do
          stub_sign_in FactoryGirl.create(:user)
        end

        it 'renders status 403' do
          do_request
          expect(response.status).to eq 403
        end
      end
    end
  end
end
