# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
        expect(controller.request).to receive(:url).and_return('http://www.aperta.tech/admin').at_least(:once)
        expect(controller).to receive(:store_location_for).with(:user, 'http://www.aperta.tech/admin')
        controller.send(:store_location_for_login_redirect)
      end
    end

    context 'when request url points to an api route' do
      it 'points to the referer instead' do
        expect(controller.request).to receive(:url).and_return('http://example.com/api/auth')
        expect(controller.request).to receive(:referer).and_return('http://www.aperta.tech/admin')
        expect(controller).to receive(:store_location_for).with(:user, 'http://www.aperta.tech/admin')
        controller.send(:store_location_for_login_redirect)
      end
    end

    context 'when request url points to an api route and request referer is not set' do
      it 'sets redirect to nil' do
        expect(controller.request).to receive(:url).and_return('http://aperta.tech/api/auth')
        expect(controller).to receive(:store_location_for).with(:user, nil)
        controller.send(:store_location_for_login_redirect)
      end
    end
  end
end
