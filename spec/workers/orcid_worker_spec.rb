require 'rails_helper'

describe OrcidWorker do
  subject(:worker) { OrcidWorker.new }
  let(:user) { FactoryGirl.create(:user) }
  let(:authorization_code) { '012345' }


  context "successful api request" do
    let(:cassette) { 'orcid_worker' }
    let(:orcid_account) { user.orcid_account }

    it 'calls exchange_code_for_token on orcid_account, then calls OrcidProfileWorker' do
      expect(OrcidAccount).to receive(:find_by).with(user_id: user.id).and_return(orcid_account)
      expect(orcid_account).to receive(:exchange_code_for_token).with(authorization_code)
      expect(OrcidProfileWorker).to receive(:perform_in).with(5.seconds, user.orcid_account.id)
      worker.perform(user.id, authorization_code)
    end
  end
end
