require "rails_helper"

describe InvitationsController do
  let(:user) { invitee }
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:invitee) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create :paper_editor_task, :with_loaded_card, paper: paper }
  let!(:queue) { FactoryGirl.create(:invitation_queue, task: task) }
  let!(:invite_letter_template) { FactoryGirl.create(:letter_template, :academic_editor_invite, journal: paper.journal) }


  describe 'GET /invitations' do
    let!(:invitation) do
      FactoryGirl.create(:invitation, :invited, invitee: invitee, invitation_queue: queue)
    end
    subject(:do_request) { get :index, format: :json }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before { stub_sign_in invitee }

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

  describe 'put /invitation/:id/update_position/' do
    let!(:invitation) do
      FactoryGirl.create :invitation,
        invitee: invitee,
        task: task,
        invitation_queue: queue
    end

    let!(:other_invitation) do
      FactoryGirl.create :invitation,
        invitee: invitee,
        task: task,
        invitation_queue: queue
    end

    subject(:do_request) do
      put :update_position,
        format: :json,
        id: invitation.id,
        position: 2
    end

    it_behaves_like 'an unauthenticated json request'

    context 'the user is authorized' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task)
          .and_return true
      end

      it 'calls invitation_queue#move_invitation_to_position' do
        allow(Invitation).to receive(:find).with(invitation.to_param).and_return(invitation)
        expect(invitation.invitation_queue).to receive(:move_invitation_to_position).with(invitation, 2)
        do_request
        data = res_body.with_indifferent_access
        expect(data[:invitations].length).to eq(2)
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
  end

  describe 'put /invitation/:id/update_primary/' do
    let!(:invitation) { FactoryGirl.create(:invitation, task: task, invitation_queue: queue, invitee: invitee) }
    let!(:primary) { FactoryGirl.create(:invitation, task: task, invitation_queue: queue, invitee: invitee) }
    subject(:do_request) do
      put :update_primary,
        format: :json,
        id: invitation.id,
        primary_id: primary.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'the user is authorized' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task)
          .and_return true
      end

      context 'the primary id is present' do
        it 'calls invitation_queue#assign_primary' do
          allow(Invitation).to receive(:find).and_return(primary)
          allow(Invitation).to receive(:find).with(primary.to_param).and_return(primary)
          allow(Invitation).to receive(:find).with(invitation.to_param).and_return(invitation)
          expect(invitation.invitation_queue).to receive(:assign_primary).with(primary: primary, invitation: invitation)

          do_request
        end

        it "responds with all the invitations in the invitation queue" do
          do_request
          data = res_body.with_indifferent_access
          expect(data[:invitations].length).to eq(2)
        end
      end

      context 'the primary id is not present' do
        subject(:do_request) do
          put :update_primary, format: :json, id: invitation.id
        end

        before do
          allow(Invitation).to receive(:find).with(invitation.to_param).and_return(invitation)
          allow(invitation.invitation_queue).to receive(:unassign_primary_from).with(invitation)
        end

        it 'calls invitation_queue#unassign_primary_from' do
          expect(invitation.invitation_queue).to receive(:unassign_primary_from).with(invitation)
          do_request
        end

        it "responds with all the invitations in the invitation queue" do
          do_request

          data = res_body.with_indifferent_access
          expect(data[:invitations].length).to eq(2)
        end
      end

      context "when the user does not have access" do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
            .and_return false
        end

        it { is_expected.to responds_with(403) }
      end
    end
  end

  describe 'GET /invitation/:id' do
    subject(:do_request) { get(:show, format: :json, id: invitation.id) }

    let!(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: invitee, invitation_queue: queue) }

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

  describe 'PUT /invitations/:id' do
    let!(:invitation) do
      FactoryGirl.create :invitation,
        invitee: invitee,
        task: task,
        invitation_queue: queue,
        position: 1,
        primary: nil
    end

    let!(:other_invitation) do
      FactoryGirl.create :invitation,
        invitee: invitee,
        task: task,
        invitation_queue: queue,
        position: 2
    end

    subject(:do_request) do
      post(
        :update,
        format: 'json',
        id: invitation.id,
        invitation: {
          email: "foo@bar.com",
          task_id: task.id,
          body: "other body",
          primary_id: other_invitation.id,
          position: 5
        }
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task).and_return(true)
      end
      it "updates the body and email" do
        do_request
        expect(invitation.reload.body).to eq("other body")
        expect(invitation.reload.email).to eq("foo@bar.com")
      end

      it "returns 204" do
        do_request
        expect(response.status).to eq(204)
      end

      it "does not update the invitation's primary" do
        do_request
        expect(invitation.reload.primary_id).to eq(nil)
      end

      it "does not update the invitation's position" do
        do_request
        expect(invitation.reload.position).to eq(1)
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

  describe 'POST /invitations' do
    subject(:do_request) do
      post(
        :create,
        format: 'json',
        invitation: {
          email: email_to_invite,
          task_id: task.id,
          body: invitation_body
        }
      )
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
          expect(invitation.invitation_queue).to eq(task.active_invitation_queue)

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

  describe 'DELETE /invitations/:id' do
    let!(:invitation) do
      FactoryGirl.create :invitation,
        invitee: invitee,
        task: task,
        invitation_queue: queue
    end

    let!(:other_invitation) do
      FactoryGirl.create :invitation,
        invitee: invitee,
        task: task,
        invitation_queue: queue
    end

    subject(:do_request) do
      delete(
        :destroy,
        format: 'json',
        id: invitation.id
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_invitations, task).and_return(true)
      end

      it 'removes the invitation from the queue and destroys it' do
        allow(Invitation).to receive(:find).and_call_original
        allow(Invitation).to receive(:find).with(invitation.to_param).and_return(invitation)
        expect(invitation.invitation_queue).to receive(:destroy_invitation).with(invitation).and_call_original

        do_request

        expect(invitation).to be_destroyed
      end

      it 'renders the remaining invitations in the queue' do
        do_request

        data = res_body.with_indifferent_access
        expect(data[:invitations].length).to eq(1)
        expect(data[:invitations][0][:id]).to eq(other_invitation.id)
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
        body: 'Invitation sent!',
        state: 'pending',
        invitee: invitee,
        task: task,
        invitation_queue: queue
      )
    end
    subject(:do_request) do
      post(
        :send_invite,
        format: 'json',
        id: invitation.to_param
      )
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
          allow(Invitation).to receive(:find).with(invitation.to_param).and_return(invitation)
          expect(invitation.invitation_queue).to receive(:send_invitation).with(invitation)
          do_request
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
        id: invitation.to_param
      )
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
          expect(invitation.actor).to eq(user)
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

      context 'when the user is not invitee' do
        let(:non_invitee_user) { FactoryGirl.create(:user) }
        before { stub_sign_in non_invitee_user }

        it 'renders status 403 for unauthorized user' do
          expect(non_invitee_user).to receive(:can?).with(:manage_invitations, task).and_return(false)
          do_request
          expect(response.status).to eq 403
        end

        it 'renders status 200 for authorized user' do
          expect(non_invitee_user).to receive(:can?).with(:manage_invitations, task).and_return(true)
          do_request
          expect(response.status).to eq 200
        end

        context 'if invitation.invitee is nil' do
          before(:each) do
            stub_sign_in non_invitee_user
            expect(non_invitee_user).to receive(:can?).with(:manage_invitations, task).and_return(true)
          end
          let(:invitation_wo_invitee) do
            FactoryGirl.create(:invitation, :invited, invitee: nil, task: task)
          end

          let(:accept_params) do
            {
              id: invitation_wo_invitee.id,
              first_name: 'Lazy',
              last_name: 'Prof',
              is_admin: true,
              format: 'json'
            }
          end

          let(:user_double) { double('User') }
          context 'with necessary params' do
            it 'creates a user with correct params' do
              expect(user_double).to receive(:email=).with(invitation_wo_invitee.email)
              expect(user_double).to receive(:auto_generate_password)
              expect(user_double).to receive(:auto_generate_username)
              expect(user_double).to receive(:valid?).and_return(true)
              expect(User).to receive(:create).with(accept_params.slice(:first_name, :last_name)).and_yield(user_double).and_return(user_double)
              put(:accept, accept_params)
            end
          end

          context 'without necessary params ' do
            it 'should return a 422 with an error message' do
              put(:accept, accept_params.except(:last_name))
              expect(response.status).to eq(422)
              expect(response.body).to match("User creation error")
            end
          end
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
            reviewer_suggestions: 'Added reviewer suggesions'
          }
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
