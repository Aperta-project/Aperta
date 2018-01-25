require 'rails_helper'

describe TahiDevise::OmniauthCallbacksController do

  before(:each) do
    # tell devise what route we are using
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#cas" do

    let(:cas_id) { FactoryGirl.attributes_for(:cas_credential).fetch(:uid) }
    let(:auth_hash) { { provider: :cas, uid: cas_id, extra: { firstName: "Bill", lastName: "Jones", emailAddress: "email@example.com", displayName: "bjones", nedId: 12345 } } }

    context "a new cas user attempts to log into plos", vcr: { cassette_name: 'ned' } do

      before(:each) do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
        expect_any_instance_of(User).to receive(:password_required?).at_least(:once).and_return(true)
      end

      it "will autogenerate a password" do
        get :cas
        expect(User.last.reload.encrypted_password).to_not be_blank
      end

      it "will redirect to the dashboard" do
        get :cas
        expect(response).to redirect_to root_path
      end
    end

    context "an existing cas user logs into plos", vcr: { cassette_name: 'ned' } do

      let(:user) { FactoryGirl.create(:user, :cas, email: 'email@example.com', password: "abcd1234", password_confirmation: "abcd1234") }
      let(:credential) { user.credentials.first }

      it "will not autogenerate a password" do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
        allow_any_instance_of(User).to receive(:password_required?).and_return(false)
        prev_password = user.encrypted_password
        get :cas
        expect(user.reload.encrypted_password).to eq(prev_password)
      end

      it "will redirect to dashboard" do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
        allow_any_instance_of(User).to receive(:password_required?).and_return(false)
        get :cas
        expect(response).to redirect_to root_path
      end

      context "with a mixed case email" do
        let(:auth_hash) { { provider: :cas, uid: cas_id, extra: { firstName: "Bill", lastName: "Jones", emailAddress: "eMail@example.com", displayName: "bjones", nedId: 12345 } } }
        it "will find a credentialless user even when NED sends mixed case emails" do
          allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
          user.credentials.destroy_all
          get :cas
          expect(response).to redirect_to root_path
          expect(user.credentials.count).to eq(1)
        end
      end
    end
  end
end
