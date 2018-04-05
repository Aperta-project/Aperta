require "rails_helper"

describe TokenInvitationsController do
  let(:user) { invitee }
  let(:invitee) { FactoryGirl.create(:user) }
  let(:phase) { FactoryGirl.create(:phase) }
  let(:task) { FactoryGirl.create :invitable_task }

  describe 'GET /invitations/:token' do
    subject(:do_request) { get :show, token: invitation.token, format: :json }
    context 'there is no user logged in' do
      context 'when the token points to an "invited" invitation' do
        let(:email) { "test@example.com" }
        let(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: nil, email: email) }
        it 'renders the show template' do
          do_request
          expect(response.body).to eq(TokenInvitationSerializer.new(invitation).to_json)
        end
      end
    end
  end

  describe 'PUT /invitations/:token' do
    subject(:do_request) { put :update, data.merge(token: invitation.token, format: :json) }
    context 'fetch and set correct invitation attributes for data' do
      before do
        expect(Invitation).to receive(:find_by!).with(token: invitation.token).and_return(invitation)
      end
      let(:data) do
        { token_invitation: { state: 'declined', decline_reason: 'foo', evil_setting: 'bar' } }
      end
      context 'with invitation in invited state' do
        let(:invitation) { FactoryGirl.create(:invitation, :invited) }
        it 'should receive .decline! method' do
          expect(invitation).to receive(:decline!).and_return(invitation)
          do_request
        end
      end
      context 'with invitation in not invited state but no feedback recorded' do
        let(:invitation) { FactoryGirl.create(:invitation, :declined) }
        it 'should receive .update_attributes method' do
          expect(invitation).to receive(:feedback_given?).and_return(false)
          expect(invitation).to receive(:update_attributes).with(data[:token_invitation].slice(:decline_reason))
          expect(invitation).to_not receive(:decline!)
          do_request
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
        expect(invitation_double).to receive_message_chain(:paper, :journal, :name).and_return('PLOS Alchemy')
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
        expect(controller.send(:use_authentication?)).to be(true)
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
          expect(controller.send(:use_authentication?)).to be(false)
        end
      end
      context 'User cannot be verified in NED' do
        let(:ned_unverified?) { true }
        it 'should return true' do
          expect(controller.send(:use_authentication?)).to be(true)
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
        expect(controller.send(:ned_unverified?)).to be(true)
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
          expect(controller.send(:ned_unverified?)).to be(true)
        end
      end
      context 'User is not in NED db' do
        let(:ned_user) { double('NedUser', email_has_account?: false) }
        it 'should return false' do
          expect(controller.send(:ned_unverified?)).to be(false)
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
        expect(controller.send(:cas_phased_signup_disabled?)).to be(true)
      end
    end

    context 'CAS_PHASED_SIGNUP_ENABLED env var is true' do
      let(:phased_env_var) { true }
      context 'with feature enabled' do
        it 'returns false' do
          expect(controller.send(:cas_phased_signup_disabled?)).to be(false)
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
        expect(Invitation).to receive(:find_by!).and_return(invitation_double)
        allow(controller).to receive(:use_authentication?).and_return(use_authentication_response)
      end
      context 'when the token points to an "invited" invitation and the user should be logged in' do
        let(:invitation_double) { double('Invitation', invitee: nil, token: 'abc', declined?: false, rescinded?: false) }
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
        let(:invitation_double) { double('Invitation', invitee: user, token: 'abc', declined?: false, rescinded?: false) }
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
          double('Invitation', token: 'blah', email: user.email, invitee_role: 'Reviewer', invitee: nil, declined?: false, rescinded?: false)
        end
        let(:dummy_cas_url) { 'http://setphaserstostun.org' }
        let(:dummy_key) { OpenSSL::PKey::EC.new('prime256v1').generate_key }
        before do
          expect(invitation_double).to receive_message_chain(:paper, :journal, :name).and_return('PLOS Alchemy')
          expect_any_instance_of(TahiEnv).to receive(:cas_phased_signup_url).and_return(dummy_cas_url)
          expect(OpenSSL::PKey::EC).to receive(:new).and_return(dummy_key)
        end
        it 'sets the redirect session value and redirects user to akita host with only a token param' do
          do_request
          stored_uri = URI(controller.send(:akita_invitation_accept_url, new_user: true))
          # stored_location_for retrieves path and query params
          expect(controller.send(:stored_location_for, :user)).to eq("#{stored_uri.path}?#{stored_uri.query}")
          redirect_uri = URI.parse(response['Location'])
          expect(redirect_uri.host).to eq(URI.parse(dummy_cas_url).host)
          expect(redirect_uri.query.starts_with?('token=')).to be true
        end
      end
    end

    context 'there is a user logged in' do
      before do
        stub_sign_in user
        expect(Invitation).to receive(:find_by!).and_return(invitation_double)
        allow(controller).to receive(:use_authentication?).and_return(true)
      end

      context 'the invitation is in an intactive state' do
        let(:invitation_double) { double('Invitation', declined?: true) }
        it 'redirects to the show page' do
          do_request
          expect(response).to redirect_to(controller.send(:client_show_invitation_url, token: request.params[:token]))
        end
      end

      context 'when the invitation hasn\'t been accepted' do
        context 'when invitation and current user emails are the same' do
          before do
            expect(Activity).to receive(:invitation_accepted!).and_return(true)
            allow(invitation_double).to receive(:actor=)
          end
          let(:invitation_double) do
            double('Invitation', invited?: true, declined?: false, rescinded?: false, email: user.email, accept!: true, paper: task.paper, invitee_role: 'Reviewer', invitee: user)
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
        end

        context 'when invitation and current user emails are not the same' do
          let(:invitation_double) do
            double('Invitation', invited?: true, declined?: false, rescinded?: false, email: 'phished@example.org', accept!: true, paper: task.paper, invitee_role: 'Reviewer', invitee_id: 123)
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
