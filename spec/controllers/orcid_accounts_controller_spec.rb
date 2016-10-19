require 'rails_helper'

describe OrcidAccountsController do
  let(:user) { FactoryGirl.create :user }
  let(:orcid_account) { user.orcid_account }

  describe "#show" do
    subject(:do_request) do
      get :show, id: orcid_account.id, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      it "calls the orcid account's serializer when rendering JSON" do
        do_request
        serializer = orcid_account.active_model_serializer.new(orcid_account, scope: orcid_account)
        expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
      end
    end
  end

  describe "#clear" do
    subject(:do_request) do
      get :clear, id: orcid_account.id, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      it "calls orcid_account.reset!" do
        allow(OrcidAccount).to receive(:find).with(orcid_account.to_param).and_return(orcid_account)
        expect(orcid_account).to receive(:reset!)
        do_request
      end

      it "calls the orcid account's serializer when rendering JSON" do
        do_request
        serializer = orcid_account.active_model_serializer.new(orcid_account, scope: orcid_account)
        expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
      end
    end
  end

  describe "#oauth_authorize_url" do
    subject(:do_request) do
      get :show, id: orcid_account.id, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      let(:oauth_authorize_url) { res_body['orcid_account']['oauth_authorize_url'] }
      let(:redirect_uri) { 'http://test.host/api/orcid/oauth' }

      it "hits the ORCID server" do
        do_request
        expect(oauth_authorize_url).to match(/#{TahiEnv.orcid_site_host}/)
      end

      it "hits /oauth/authorize" do
        do_request
        expect(oauth_authorize_url).to match(%r{/oauth/authorize})
      end

      it "contains the ORCID_KEY" do
        do_request
        expect(oauth_authorize_url).to match(/#{TahiEnv.orcid_key}/)
      end

      it "passes a response_type of 'code'" do
        do_request
        expect(oauth_authorize_url).to match(/response_type=code/)
      end

      it "requests a scope of '/read-limited'" do
        do_request
        expect(oauth_authorize_url).to match(%r{scope=/read-limited})
      end

      it "requests only one scope" do
        do_request
        expect(oauth_authorize_url).not_to match(%r{scope=/[\w-]*%20/})
      end

      it "passes in a redirect uri" do
        do_request
        expect(oauth_authorize_url).to match(/redirect_uri=#{redirect_uri}/)
      end
    end
  end
end
