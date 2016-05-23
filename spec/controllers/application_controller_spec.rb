require 'rails_helper'

describe ApplicationController do
  include Rails.application.routes.url_helpers

  controller do
    def index
      redirect_to "/"
    end
  end

  describe "signing out when CAS_LOGOUT_PATH is defined" do
    controller do
      def destroy
        sign_out
        redirect_to after_sign_out_path_for(current_user)
      end
    end

    let(:cas_logout_url) { 'http://cas.example.com/user/logout' }
    let(:user) { FactoryGirl.build(:user) }

    before do
      routes.draw { delete "destroy" => "anonymous#destroy" }
      stub_sign_in user
    end

    it "redirects the user to CAS LOGOUT URL with a new session query param" do
      ClimateControl.modify CAS_LOGOUT_URL: cas_logout_url do
        delete :destroy
        expect(response.redirection?).to be(true)

        query = { service: new_user_session_url }.to_query
        redirect_url = URI.join(cas_logout_url, "?#{query}").to_s
        expect(response.location).to eq(redirect_url)
      end
    end
  end
end
