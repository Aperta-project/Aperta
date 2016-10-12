require 'rails_helper'

describe OrcidAccountsController do
  let(:user) { FactoryGirl.create :user }
  let(:orcid_account) { user.orcid_account }


  describe "#show" do
    subject(:do_request) do
      get :show, id: user.id, format: :json
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
    it "resets account values" do

    end
  end

  describe "#orcid_account" do
    it "returns an orcid account"
  end

  describe "#oauth_authorize_url" do
    it "returns a URL"
  end

  describe "#redirect_uri" do
    it "computes a uri"
  end


  #   # ---------------------------------
  #
  #
  # describe '#show' do
  #   subject(:do_request) do
  #     get :show, id: user.id, format: :json
  #   end
  #
  #   it_behaves_like 'an unauthenticated json request'
  #
  #   context 'when the user is signed in' do
  #     before do
  #       stub_sign_in(user)
  #     end
  #
  #     it "calls the users's serializer when rendering JSON" do
  #       expect_any_instance_of(UsersController).to receive(:requires_user_can).with(:manage_user, Journal) { true }
  #       do_request
  #       serializer = user.active_model_serializer.new(user, scope: user)
  #       expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
  #     end
  #   end
  # end
end
