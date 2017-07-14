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
          expect(invitation.reviewer_suggestions).to eq("None")
          expect(invitation.decline_reason).to eq("reasons")
        end
      end
    end
  end

  describe '#jwt_encoded_payload' do
    context 'should return an encrypted token which can be decrypted' do
      let(:jwt_decoded_payload) do
        token = controller.send(:jwt_encoded_payload)
        JWT.decode(token, dummy_key, true, algorithm: 'ES256').first
      end
      let(:invitation_double) { double('Invitation', token: 'blah', email: user.email) }
      let(:dummy_key) { OpenSSL::PKey::EC.new('prime256v1').generate_key }
      before do
        expect(controller).to receive(:invitation).at_least(:once).and_return(invitation_double)
        invitation_double.stub_chain(:paper, :journal, :name).and_return('PLOS Alchemy')
        expect(OpenSSL::PKey::EC).to receive(:new).and_return(dummy_key)
      end
      it 'has four keys: destination, heading, subheading, email' do
        expect(jwt_decoded_payload.keys).to include('destination', 'heading', 'subheading', 'email')
      end
      it 'has a the invitation email set to the email key' do
        expect(jwt_decoded_payload['email']).to eq(invitation_double.email)
      end
      it 'the destination value is the omniauth callback url with correct redirect url' do
        expect(jwt_decoded_payload['destination']).to eq(controller.send(:akita_omniauth_callback_url))
      end
    end
  end

  describe '#use_authentication?' do
    context 'the invitation does not have an invitee_id' do
      let(:invitation_double) { double('Invitation', email: 'ned@flancrest.com', invitee_id: nil) }
      before { expect(controller).to receive(:invitation).at_least(:once).and_return(invitation_double) }
      context 'the AKITA_INTEGRATION feature flag is false' do
        before { expect(FeatureFlag).to receive(:[]).with('AKITA_INTEGRATION').and_return(false) }
        it 'should return true' do
          controller.send(:use_authentication?).should be true
        end
      end
      context 'the AKITA_INTEGRATION ff is true' do
        before do
          expect(FeatureFlag).to receive(:[]).with('AKITA_INTEGRATION').and_return(true)
        end
        context 'and the phased sign up url is missing' do
          before { expect_any_instance_of(TahiEnv).to receive(:cas_phased_signup_url).and_return(nil) }
          it 'should return true' do
            controller.send(:use_authentication?).should be true
          end
        end
        context 'and phased signup url is present' do
          before do
            expect_any_instance_of(TahiEnv).to receive(:cas_phased_signup_url).and_return('http://setphaserstostun.org')
          end
          context 'but NED is not enabled' do
            before { expect(NedUser).to receive(:enabled?).and_return(false) }
            it 'should return true' do
              controller.send(:use_authentication?).should be true
            end
          end
          context 'and NED is enabled' do
            before do
              expect(NedUser).to receive(:enabled?).and_return(true)
              expect(NedUser).to receive(:new).and_return(ned_user)
            end
            context 'and the invitation email already exists in NED' do
              let(:ned_user) { double('NedUser', email_has_account?: true) }
              it 'should return true' do
                controller.send(:use_authentication?).should be true
              end
            end
            context 'and invitation email does not exit in NED' do
              let(:ned_user) { double('NedUser', email_has_account?: false) }
              it 'should return false' do
                controller.send(:use_authentication?).should be false
              end
            end
          end
        end
      end
    end
  end

  describe 'GET /invitations/:token/accept' do
    subject(:do_request) { get :accept, token: 'soCrypticMuchMystery' }
    context 'there is no user logged in' do
      before { expect(controller).to receive(:use_authentication?).and_return(use_authentication_response) }
      context 'when the token points to an "invited" invitation and the user should be logged in' do
        let(:use_authentication_response) { true }
        it 'redirects user to login page' do
          do_request
          expect(response).to redirect_to(new_user_session_url)
        end
      end
      context 'the user should go through akita phased signup' do
        let(:use_authentication_response) { false }
        let(:invitation_double) do
          double('Invitation', token: 'blah', email: user.email)
        end
        let(:dummy_cas_url) { 'http://setphaserstostun.org' }
        let(:dummy_key) { OpenSSL::PKey::EC.new('prime256v1').generate_key }
        before do
          expect(Invitation).to receive(:find_by_token!).and_return(invitation_double)
          invitation_double.stub_chain(:paper, :journal, :name).and_return('PLOS Alchemy')
          expect_any_instance_of(TahiEnv).to receive(:cas_phased_signup_url).and_return(dummy_cas_url)
          expect(OpenSSL::PKey::EC).to receive(:new).and_return(dummy_key)
        end
        it 'redirects user to akita host with only a token param' do
          do_request
          redirect_uri = URI.parse(response['Location'])
          expect(redirect_uri.host).to eq(URI.parse(dummy_cas_url).host)
          expect(redirect_uri.query.starts_with?('token=')).to be true
        end
      end
    end

    context 'there is a user logged in' do
      before do
        stub_sign_in user
        expect(Invitation).to receive(:find_by_token!).and_return(invitation_double)
        expect(controller).to receive(:use_authentication?).and_return(true)
      end
      context 'when the invitation hasn\'t been accepted' do
        context 'when invitation and current user emails are the same' do
          before { expect(Activity).to receive(:invitation_accepted!).and_return(true) }
          let(:invitation_double) do
            double('Invitation', invited?: true, email: user.email, accept!: true, paper: task.paper, invitee_role: 'Reviewer')
          end

          it 'creates an Activity' do
            do_request
          end

          it 'accepts the user\'s invitation' do
            expect(invitation_double).to receive(:accept!)
            do_request
          end

          it 'redirects user to the manuscript and sets a flash notice' do
            do_request
            expect(response).to redirect_to("/papers/#{invitation_double.paper.short_doi}")
            expect(flash[:notice]).to include("Thank you for agreeing to review")
          end

          context 'Inviting an academic editor' do
            let(:invitation_double) do
              double('Invitation', invitee_role: 'Academic Editor', invited?: true, email: user.email, accept!: true, paper: task.paper)
            end
            it 'flashes appropriate language' do
              do_request
              expect(flash[:notice]).to include("Thank you for agreeing to edit")
            end
          end
        end

        context 'when invitation and current user emails are not the same' do
          let(:invitation_double) do
            double('Invitation', invited?: true, email: 'phished@plos.org', accept!: true, paper: task.paper)
          end
          it 'does not accept the user\'s invitation' do
            expect(invitation_double).not_to receive(:accept!)
            do_request
          end

          it 'redirects user to the manuscript' do
            do_request
            expect(response).to redirect_to("/papers/#{invitation_double.paper.short_doi}")
          end
        end
      end

      context 'when the invitation has been accepted' do
        let(:invitation_double) do
          double('Invitation', invited?: false, email: user.email, paper: task.paper)
        end
        it 'does not try to accept again and redirects to manuscript' do
          expect(invitation_double).to receive(:invited?)
          expect(invitation_double).not_to receive(:accept!)
          expect(Activity).not_to receive(:invitation_accepted!)
          do_request
          expect(response).to redirect_to("/papers/#{invitation_double.paper.short_doi}")
        end
      end
    end
  end
end
