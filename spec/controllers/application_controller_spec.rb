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

    let(:cas_host){ 'cas-aperta-integration.plos.org' }
    let(:cas_logout_url) { 'http://example.com/cas/logout' }
    let(:cas_ssl){ 'true' }
    let(:cas_env_vars) do
      {
        CAS_HOST: cas_host,
        CAS_SSL: cas_ssl,
        CAS_LOGOUT_URL: cas_logout_url
      }
    end

    let(:user) { FactoryGirl.build(:user) }

    before do
      routes.draw { delete 'destroy' => 'anonymous#destroy' }
      stub_sign_in user
    end

    it 'redirects the user to CAS_LOGOUT_URL with a new session query param' do
      ClimateControl.modify(cas_env_vars) do
        delete :destroy
        expect(response.redirection?).to be(true)

        query = { service: new_user_session_url }.to_query
        redirect_url = URI.join('http://example.com/cas/logout', "?#{query}").to_s
        expect(response.location).to eq(redirect_url)
      end
    end

    context 'and the CAS_LOGOUT_URL is a relative path' do
      let(:cas_logout_url) { '/cas/logout' }

      it 'redirects the user to a constructed URL based on other CAS env variables' do
        ClimateControl.modify(cas_env_vars) do
          delete :destroy
          expect(response.redirection?).to be(true)

          query = { service: new_user_session_url }.to_query
          redirect_url = URI.join("https://#{cas_host}/#{cas_logout_url}", "?#{query}").to_s
          expect(response.location).to eq(redirect_url)
        end
      end
    end
  end

  describe '#store_location_for_login_redirect' do
    context 'when the request url is ok' do
      it 'points to the url' do
        controller.request.stub url: 'http://www.aperta.tech/admin'

        expect(controller).to receive(:store_location_for)
          .with(:user, 'http://www.aperta.tech/admin')

        controller.send(:store_location_for_login_redirect)
      end
    end

    context 'when request url points to an api route' do
      it 'points to the referer instead' do
        controller.request.stub url: 'http://example.com/api/auth'
        controller.request.stub referer: 'http://www.aperta.tech/admin'

        expect(controller).to receive(:store_location_for)
          .with(:user, 'http://www.aperta.tech/admin')

        controller.send(:store_location_for_login_redirect)
      end
    end

    context 'when request url points to an api route and request referer is not set' do
      it 'points to the dashboard' do
        controller.request.stub url: 'http://aperta.tech/api/auth'
        controller.request.stub host: 'http://aperta.tech/'

        expect(controller).to receive(:store_location_for)
          .with(:user, 'http://aperta.tech/')
          
        controller.send(:store_location_for_login_redirect)
      end
    end
  end
end
