require "rails_helper"

describe TokenInvitationsController do
  let(:user) { invitee }
  let(:invitee) { FactoryGirl.create(:user) }
  let(:phase) { FactoryGirl.create(:phase) }
  let(:task) { FactoryGirl.create :invitable_task }

  describe 'GET /invitations/:token' do
    subject(:do_request) { get :show, token: invitation.token }
    context 'there is no user logged in' do
      context 'when the token points to an "invited" invitation' do
        let(:email) { "test@example.com" }
        let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: nil, email: email) }
        it 'renders the show template' do
          do_request
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe 'POST #decline' do
    subject(:do_request) { post :decline, token: invitation.token }
    context 'when the token points to an "invited" invitation' do
      let(:email) { "test@example.com" }
      let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: nil, email: email) }
      it 'declines the invitation' do
        do_request
        expect(invitation.reload.state).to eq("declined")
      end

      it 'creates an Activity' do
        expected_activity = {
          message: "#{email} declined invitation as #{task.invitee_role.capitalize}",
          feed_name: 'workflow'
        }
        expect(Activity).to receive(:create).with hash_including(expected_activity)
        do_request
      end
    end

    context 'when the token points to a "declined" invitation' do
      let(:invitation) { FactoryGirl.create(:invitation, :declined) }
      it 'redirects to root' do
        do_request
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #feedback_form' do
    subject(:do_request) { get :feedback_form, token: invitation.token }
    context 'there is no user logged in' do
      context 'when the token points to a "declined" invitation' do
        context 'the invite has no feedback or reviewer suggestions' do
          let(:invitation) { FactoryGirl.create(:invitation, :declined) }
          it 'renders the feedback template' do
            do_request
            expect(response).to render_template(:feedback_form)
          end
        end

        it 'redirects to the /thank_you page if the invite has feedback' do
          invitation = FactoryGirl.create(:invitation,
            :declined,
            decline_reason: "Foo")
          get :feedback_form, token: invitation.token
          expect(response).to redirect_to(invitation_thank_you_path(invitation.token))
        end

        it 'redirects to the /thank_you page if the invite has reviewer suggestions' do
          invitation = FactoryGirl.create(:invitation,
            :declined,
            reviewer_suggestions: "dave@example.com")
          get :feedback_form, token: invitation.token
          expect(response).to redirect_to(invitation_thank_you_path(invitation.token))
        end
      end

      context 'when the invitation is in any other state' do
        let(:invitation) { FactoryGirl.create(:invitation, :accepted) }
        it 'redirects to the root page' do
          do_request
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'the user is signed in' do
      let(:invitation) { FactoryGirl.create(:invitation, :invited) }
      before { stub_sign_in user }
      it 'redirects the user to the root page' do
        do_request
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #thank_you' do # this is the Thank-You screen
    subject(:do_request) { get :thank_you, token: invitation.token }
    context 'the user is signed in' do
      let(:invitation) { FactoryGirl.create(:invitation, :declined) }
      before { stub_sign_in user }
      it 'redirects to the root page' do
        do_request
        expect(response).to redirect_to(root_path)
      end
    end

    context 'the user is not signed in' do
      context 'when the token points to a "declined" invitation' do
        let(:invitation) { FactoryGirl.create(:invitation, :declined) }
        it 'renders the template' do
          do_request
          expect(response).to render_template(:thank_you)
        end
      end

      context 'when the invitation is in any other state' do
        let(:invitation) { FactoryGirl.create(:invitation, :accepted) }
        it 'redirects to the root page' do
          do_request
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe 'POST #feedback' do
    subject(:do_request) do
      post :feedback,
        token: invitation.token,
        invitation: {
          reviewer_suggestions: "new reviewer",
          decline_reason: "I decline"
        }
    end

    context "the invite is in a state other than 'declined'" do
      let(:invitation) { FactoryGirl.create(:invitation, :accepted) }
      it 'redirects to the root page' do
        do_request
        expect(response).to redirect_to(root_path)
      end
    end

    context "the invite is in a 'declined' state" do
      let(:invitation) { FactoryGirl.create(:invitation, :declined) }

      it 'redirects to the thank you page' do
        do_request
        expect(response).to redirect_to(invitation_thank_you_path(invitation.token))
      end

      context 'the invite has no feedback or reviewer suggestions' do
        it 'updates the invite with the given attributes' do
          do_request
          invitation.reload
          expect(invitation.reviewer_suggestions).to eq("new reviewer")
          expect(invitation.decline_reason).to eq("I decline")
        end
      end

      context 'the invite already has either feedback or suggestions' do
        let(:invitation) { FactoryGirl.create(:invitation, :declined, decline_reason: "reasons") }
        it 'does not update the invite' do
          do_request
          invitation.reload
          expect(invitation.reviewer_suggestions).to eq("n/a")
          expect(invitation.decline_reason).to eq("reasons")
        end
      end
    end
  end
end
