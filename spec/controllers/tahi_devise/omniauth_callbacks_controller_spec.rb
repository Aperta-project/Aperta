require 'rails_helper'

describe TahiDevise::OmniauthCallbacksController do

  before(:each) do
    # tell devise what route we are using
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#orcid" do

    context "a new orcid user attempts to log into plos" do
      before(:each) do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return({uid: "uid", provider: "orcid"})
      end

      it "will redirect to registration page" do
        get :orcid
        expect(response).to redirect_to new_user_registration_path
      end
    end

    context "an existing orcid user logs into plos" do

      before(:each) do
        user = FactoryGirl.create(:user, :orcid)
        credential = user.credentials.first
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return({uid: credential.uid, provider: credential.provider})
      end

      it "will redirect to dashboard" do
        get :orcid
        expect(response).to redirect_to root_path
      end
    end

  end

end
