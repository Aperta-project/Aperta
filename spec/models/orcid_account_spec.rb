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

describe OrcidAccount do
  let(:orcid_account) do
    # account used:  "Aperta Test" apertatest@mailinator.com/password1
    FactoryGirl.create(:orcid_account,
      identifier: '0000-0001-7532-4518',
      access_token: 'abc-123')
  end
  let(:orcid_key) { 'APP-foo' }
  let(:orcid_secret) { '0000-bar' }
  let(:cassette) { 'orcid_account' }

  around do |example|
    envs = {
      ORCID_KEY: orcid_key,
      ORCID_SECRET: orcid_secret,
      ORCID_SITE_HOST: 'sandbox.orcid.org',
      ORCID_API_HOST: 'api.sandbox.orcid.org',
      ORCID_API_VERSION: '2.0'
    }
    ClimateControl.modify(envs) do
      VCR.use_cassette(cassette, match_requests_on: [:uri, :method, :headers]) do
        example.run
      end
    end
  end

  describe '#authenticated?' do
    context 'with access token' do
      let(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account,
          identifier: 'a', access_token: 'b'
        )
      end
      it 'returns truthy' do
        expect(orcid_account.authenticated?).to be_truthy
      end
    end

    context 'without access token' do
      let(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account, identifier: 'a')
      end
      it 'returns truthy' do
        expect(orcid_account.authenticated?).to be_falsey
      end
    end
  end

  describe '#exchange_code_for_token' do
    # Get this from after authorizing on orcid.org. Click on the oauth link,
    # authorize aperta, and capture the authorization code from the callback.
    # account used apertatest@mailinator.com/password1
    let(:authorization_code) { '4LJmXp' }
    # This is the orcid returned with the test account. Update this when
    # refreshing the VCR cassettee.
    let(:orcid_identifier) { '0000-0001-7532-4518' }
    let(:cassette) { 'orcid_authorization' }
    let(:orcid_account) do
      FactoryGirl.create(:orcid_account,
        identifier: nil,
        access_token: nil)
    end

    context 'server returns http error code' do
      let(:authorization_code) { 'ZZZZZZ' }
      let(:cassette) { 'orcid_authorization_failure_bad_code' }

      it 'raises OrcidAccount::APIError on an error message in message body' do
        expect do
          orcid_account.exchange_code_for_token(authorization_code)
        end.to raise_error(OrcidAccount::APIError)
      end
    end

    context 'server returns http error code' do
      let(:orcid_key) { 'Bogus-key' }
      let(:cassette) { 'orcid_authorization_failure_http_error_code' }

      it 'raises OrcidAccount::APIError on a non 200 response' do
        expect do
          orcid_account.exchange_code_for_token(authorization_code)
        end.to raise_error(OrcidAccount::APIError)
      end
    end

    context 'user has correct credentials' do
      it 'receives an access token' do
        orcid_account.exchange_code_for_token(authorization_code)
        orcid_account.update_orcid_profile!
        expect(orcid_account.access_token).not_to be_empty
      end

      it 'saves the orcid identifier' do
        orcid_account.exchange_code_for_token(authorization_code)
        orcid_account.update_orcid_profile!
        expect(orcid_account.identifier).to eq(orcid_identifier)
      end
    end
  end

  describe '#update_orcid_profile!' do
    it 'updates the name on orcid profile' do
      orcid_account.update_attributes(name: nil)
      orcid_account.update_orcid_profile!
      expect(orcid_account.name).to_not be_nil
    end

    context 'no identifier' do
      let(:orcid_account) do
        FactoryGirl.create(:orcid_account,
          access_token: '77ca0753-a8ac-491b-a1c4-0dbaa0c486d0')
      end

      it 'raises OrcidAccount::APIError' do
        expect do
          orcid_account.update_orcid_profile!
        end.to raise_error(OrcidAccount::APIError)
      end
    end

    context 'no access_token' do
      let(:orcid_account) do
        FactoryGirl.create(:orcid_account,
          identifier: '0000-0002-8398-4521')
      end

      it 'raises OrcidAccount::APIError' do
        expect do
          orcid_account.update_orcid_profile!
        end.to raise_error(OrcidAccount::APIError)
      end
    end
  end

  describe '#profile_url' do
    context 'with identifier' do
      let(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account, identifier: 'my_id')
      end
      let(:profile_url) { 'http://sandbox.orcid.org/my_id' }

      it 'returns the remote profile url' do
        expect(orcid_account.profile_url).to eq(profile_url)
      end
    end

    context 'without identifier' do
      let(:orcid_account) { FactoryGirl.build_stubbed(:orcid_account) }
      it 'returns nil' do
        expect(orcid_account.profile_url).to be_nil
      end
    end
  end

  describe '#access_token_valid' do
    context 'with expires_at and access_token' do
      let!(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account, access_token: 'token', expires_at: Time.current.utc)
      end

      context 'expires_at is in the past' do
        it 'returns false' do
          Timecop.freeze(Time.current.utc + 5.seconds) do
            expect(orcid_account.access_token_valid).to be_falsy
          end
        end
      end

      context 'expires_at is in the future' do
        it 'returns false' do
          Timecop.freeze(Time.current.utc - 5.seconds) do
            expect(orcid_account.access_token_valid).to be_truthy
          end
        end
      end
    end

    context 'without expires_at' do
      let!(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account,
          access_token: nil,
          expires_at: Time.current.utc + 50.seconds)
      end
      it 'returns false' do
        expect(orcid_account.access_token_valid).to be_falsy
      end
    end
  end

  describe '#status' do
    let!(:orcid_account) do
      FactoryGirl.build_stubbed(:orcid_account)
    end

    it 'is `unauthenticated` when access_token is falsy' do
      expect(orcid_account.status).to eq(:unauthenticated)
    end

    it 'is `authenticated` when access_token_valid is truthy' do
      allow(orcid_account).to receive(:access_token).and_return('token')
      allow(orcid_account).to receive(:access_token_valid).and_return(true)
      expect(orcid_account.status).to eq(:authenticated)
    end

    it 'is `access_token_expired` when access_token is truthy and access_token_valid is falsy' do
      allow(orcid_account).to receive(:access_token).and_return('token')
      allow(orcid_account).to receive(:access_token_valid).and_return(false)
      expect(orcid_account.status).to eq(:access_token_expired)
    end
  end

  describe 'oauth_authorize_url' do
    let!(:orcid_account) do
      FactoryGirl.build_stubbed(:orcid_account)
    end

    let(:redirect_uri) { orcid_account.redirect_uri }
    let(:url) { orcid_account.oauth_authorize_url }

    it "hits the ORCID server" do
      expect(url).to match(/#{TahiEnv.orcid_site_host}/)
    end

    it "hits /oauth/authorize" do
      expect(url).to match(%r{/oauth/authorize})
    end

    it "contains the ORCID_KEY" do
      expect(url).to match(/#{TahiEnv.orcid_key}/)
    end

    it "passes a response_type of 'code'" do
      expect(url).to match(/response_type=code/)
    end

    it "requests a scope of '/read-limited'" do
      expect(URI.unescape(url)).to match(%r{scope=/read-limited})
    end

    it "requests only one scope" do
      expect(URI.unescape(url)).not_to match(%r{scope=/[\w-]*%20/})
    end

    it "passes in a redirect uri" do
      expect(URI.unescape(url)).to match(/redirect_uri=#{redirect_uri}/)
    end

    context 'respects the protocol set in default_url_options' do

      around do |example|
        original_options = Rails.application.routes.default_url_options.dup
        Rails.application.routes.default_url_options[:protocol] = "https"
        example.run
        Rails.application.routes.default_url_options = original_options
      end

      it "passes in a redirect uri" do
        expect(URI.unescape(url)).to match(/redirect_uri=#{redirect_uri}/)
      end
    end
  end
end
