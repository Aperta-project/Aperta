require 'rails_helper'

describe OrcidWorker do
  subject(:worker) { OrcidWorker.new }
  let(:user) { FactoryGirl.create(:user) }
  let(:orcid_key) { 'APP-PLM33GS3DKZ60O79' }
  let(:orcid_secret) { '056cab03-aebe-4cb2-86d1-0011184af5ee' }

  # Get this from after authorizing on orcid.org. Click on the oauth link, authorize aperta, and capture the authorization code from the callback.
  let(:authorization_code) { 'C3b6Z2' }

  around do |example|
    envs = {
      ORCID_KEY: orcid_key,
      ORCID_SECRET: orcid_secret,
      ORCID_SITE_HOST: 'sandbox.orcid.org',
      ORCID_API_HOST: 'api.sandbox.orcid.org',
      ORCID_API_VERSION: '1.2'
    }
    ClimateControl.modify(envs) do
      VCR.use_cassette(cassette, match_requests_on: [:uri, :method, :headers]) do
        example.run
      end
    end
  end

  context "successful api request" do
    # this is the orcid returned with the test account. Update this when refreshing the VCR cassettee
    let(:orcid_identifier) { '0000-0002-8398-4521' }
    let(:cassette) { 'orcid_worker' }

    it 'receives an access token' do
      worker.perform(user.id, authorization_code)
      expect(user.orcid_account.access_token).not_to be_empty
    end

    it 'saves the orcid identifier' do
      worker.perform(user.id, authorization_code)
      expect(user.orcid_account.identifier).to eq(orcid_identifier)
    end

    it 'calls OrcidProfileWorker' do
      expect(OrcidProfileWorker).to receive(:perform_in).with(5.seconds, user.orcid_account.id)
      worker.perform(user.id, authorization_code)
    end
  end

  context 'server returns http error code' do
    let(:authorization_code) { 'ZZZZZZ' }
    let(:cassette) { 'orcid_worker_failure_bad_code' }

    it 'raises OrcidAccount::APIError on an error message in message body' do
      expect do
        worker.perform(user.id, authorization_code)
      end.to raise_error(OrcidAccount::APIError)
    end
  end

  context 'server returns http error code' do
    let(:orcid_key) { 'Bogus-key' }
    let(:cassette) { 'orcid_worker_failure_http_error_code' }

    it 'raises OrcidAccount::APIError on a non 200 response' do
      expect do
        worker.perform(user.id, authorization_code)
      end.to raise_error(OrcidAccount::APIError)
    end
  end
end
