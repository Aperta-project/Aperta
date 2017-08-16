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
      it 'redirects to inactive' do
        do_request
        expect(response).to redirect_to(invitation_inactive_path(invitation.token))
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
      let(:invitation_double) do
        double('Invitation', token: 'blah', email: user.email, invitee_role: 'Reviewer')
      end
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
    before do
      expect(controller).to receive(:cas_phased_signup_disabled?).at_least(:once).and_return(phased_disabled?)
    end
    context 'CAS phased signup is not setup' do
      let(:phased_disabled?) { true }
      it 'should return true' do
        controller.send(:use_authentication?).should be true
      end
    end
    context 'CAS phased signup is setup' do
      let(:phased_disabled?) { false }
      before do
        expect(controller).to receive(:ned_unverified?).at_least(:once).and_return(ned_unverified?)
      end
      context 'User can be verified in NED' do
        let(:ned_unverified?) { false }
        it 'should return false' do
          controller.send(:use_authentication?).should be false
        end
      end
      context 'User cannot be verified in NED' do
        let(:ned_unverified?) { true }
        it 'should return true' do
          controller.send(:use_authentication?).should be true
        end
      end
    end
  end

  describe '#ned_unverified?' do
    before do
      expect(NedUser).to receive(:enabled?).and_return(ned_enabled?)
    end
    context 'NED is not enabled' do
      let(:ned_enabled?) { false }
      it 'should return true' do
        controller.send(:ned_unverified?).should be true
      end
    end
    context 'Ned is enabled' do
      let(:invitation_double) { double('Invitation', email: 'ned@flancrest.com') }
      let(:ned_enabled?) { true }
      before do
        expect(NedUser).to receive(:new).and_return(ned_user)
        expect(controller).to receive(:invitation).and_return(invitation_double)
      end
      context 'User is in NED db' do
        let(:ned_user) { double('NedUser', email_has_account?: true) }
        it 'should return true' do
          controller.send(:ned_unverified?).should be true
        end
      end
      context 'User is not in NED db' do
        let(:ned_user) { double('NedUser', email_has_account?: false) }
        it 'should return false' do
          controller.send(:ned_unverified?).should be false
        end
      end
    end
  end

  describe '#cas_phased_signup_disabled?' do
    before do
      expect_any_instance_of(TahiEnv).to receive(:cas_phased_signup_enabled?).and_return(phased_env_var)
    end
    context 'CAS_PHASED_SIGNUP_ENABLED env var is false' do
      let(:phased_env_var) { false }

      it 'should return false' do
        controller.send(:cas_phased_signup_disabled?).should be true
      end
    end

    context 'CAS_PHASED_SIGNUP_ENABLED env var is true' do
      let(:phased_env_var) { true }
      before do
        expect(FeatureFlag).to receive(:[]).with('CAS_PHASED_SIGNUP').and_return(cas_ff)
      end
      context 'with feature flag enabled' do
        let(:cas_ff) { true }
        it 'returns false' do
          controller.send(:cas_phased_signup_disabled?).should be false
        end
      end
      context 'with feature flag disabled' do
        let(:cas_ff) { false }
        it 'returns false' do
          controller.send(:cas_phased_signup_disabled?).should be true
        end
      end
    end
  end

  describe '#akita_invitation_accept_url' do
    let(:invitation_double) { double('Invitation', token: 'abc') }
    let(:url_args) do
      {
        controller: 'token_invitations',
        action: 'accept',
        token: invitation_double.token,
        new_user: true
      }
    end
    it 'passes the expected hash to url_for' do
      allow(controller).to receive(:invitation).and_return(invitation_double)
      expect(controller).to receive(:url_for).with(url_args)
      controller.send(:akita_invitation_accept_url, new_user: true)
    end
  end

  describe '#akita_omniauth_callback_url' do
    let(:dummy_url) { 'http://dummyurl.com' }
    let(:url_args) do
      {
        controller: 'tahi_devise/omniauth_callbacks',
        action: 'cas',
        url: dummy_url
      }
    end
    it 'passes the expected has to url_for' do
      expect(controller).to receive(:akita_invitation_accept_url).and_return(dummy_url)
      expect(controller).to receive(:url_for).with(url_args)
      controller.send(:akita_omniauth_callback_url)
    end
  end

  describe 'GET /invitations/:token/accept' do
    subject(:do_request) { get :accept, token: 'soCrypticMuchMystery' }
    subject(:new_user_do_request) do
      get :accept, token: 'soCrypticMuchMystery', new_user: true
    end
    context 'there is no user logged in' do
      before do
        expect(Invitation).to receive(:find_by_token!).and_return(invitation_double)
        allow(controller).to receive(:use_authentication?).and_return(use_authentication_response)
      end
      context 'when the token points to an "invited" invitation and the user should be logged in' do
        let(:invitation_double) { double('Invitation', invitee_id: nil, token: 'abc', declined?: false, rescinded?: false) }
        let(:use_authentication_response) { true }
        before do
          expect_any_instance_of(TahiEnv).to receive(:cas_enabled?).and_return(cas_enabled)
        end
        context 'CAS is disabled' do
          let(:cas_enabled) { false }
          it 'redirects user to login page' do
            do_request
            expect(response).to redirect_to(new_user_session_url)
          end
        end
        context 'CAS is enabled' do
          let(:cas_enabled) { true }
          let(:dummy_url) { 'http://wat.com' }
          let(:dummy_params) { { url: dummy_url } }
          let(:dummy_redirect) { 'http://redirect.com' }
          it 'redirects user to login page' do
            allow(controller).to receive(:akita_invitation_accept_url).and_return(dummy_url)
            expect(controller).to receive(:omniauth_authorize_path).with(:user, 'cas', dummy_params).and_return(dummy_redirect)
            do_request
            expect(response).to redirect_to(dummy_redirect)
          end
        end
      end
      context 'when the token points to an "invited" invitation with an invitee_id and the user should be logged in' do
        let(:invitation_double) { double('Invitation', invitee_id: 1234, token: 'abc', declined?: false, rescinded?: false) }
        let(:use_authentication_response) { false }
        it 'redirects user to login page' do
          allow_any_instance_of(TahiEnv).to receive(:cas_enabled?).and_return(false)
          do_request
          expect(response).to redirect_to(new_user_session_url)
        end
      end
      context 'the user should go through akita phased signup' do
        let(:use_authentication_response) { false }
        let(:invitation_double) do
          double('Invitation', token: 'blah', email: user.email, invitee_role: 'Reviewer', invitee_id: nil, declined?: false, rescinded?: false)
        end
        let(:dummy_cas_url) { 'http://setphaserstostun.org' }
        let(:dummy_key) { OpenSSL::PKey::EC.new('prime256v1').generate_key }
        before do
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
        allow(controller).to receive(:use_authentication?).and_return(true)
      end
      context 'when the invitation hasn\'t been accepted' do
        context 'when invitation and current user emails are the same' do
          before { expect(Activity).to receive(:invitation_accepted!).and_return(true) }
          let(:invitation_double) do
            double('Invitation', invited?: true, declined?: false, rescinded?: false, email: user.email, accept!: true, paper: task.paper, invitee_role: 'Reviewer', invitee_id: 123)
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

          it 'sets adds to the flash notice if there is a new_user query param' do
            new_user_do_request
            expect(flash[:notice]).to include("Your PLOS account was successfully created.")
          end

          context 'Inviting an academic editor' do
            let(:invitation_double) do
              double('Invitation', invitee_role: 'Academic Editor', invited?: true, declined?: false, rescinded?: false, email: user.email, accept!: true, paper: task.paper, invitee_id: 123)
            end
            it 'flashes appropriate language' do
              do_request
              expect(flash[:notice]).to include("Thank you for agreeing to edit")
            end
          end
        end

        context 'when invitation and current user emails are not the same' do
          let(:invitation_double) do
            double('Invitation', invited?: true, declined?: false, rescinded?: false, email: 'phished@plos.org', accept!: true, paper: task.paper, invitee_role: 'Reviewer', invitee_id: 123)
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
          double('Invitation', invited?: false, declined?: false, rescinded?: false, email: user.email, paper: task.paper, invitee_id: 123)
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
