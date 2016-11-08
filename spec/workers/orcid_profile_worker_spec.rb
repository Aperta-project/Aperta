require 'rails_helper'

describe OrcidProfileWorker do
  subject(:worker) { OrcidProfileWorker.new }
  let!(:user) { FactoryGirl.create(:user) }
  let(:orcid_account) { user.orcid_account }

  it 'calls update profile' do
    expect(orcid_account).to receive(:update_orcid_profile!)
    expect(OrcidAccount).to receive(:find) { orcid_account }
    worker.perform(user.orcid_account.id)
  end
end
