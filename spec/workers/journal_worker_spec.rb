require 'rails_helper'
RSpec.describe JournalWorker, type: :worker do
  describe JournalWorker do
    subject(:worker) { JournalWorker.new }
    let(:loader) { CustomCard::FileLoader }
    let(:journal) do
      JournalFactory.create(
        name: 'Journal of the Stars',
        doi_journal_prefix: 'journal.SHORTJPREFIX1',
        doi_publisher_prefix: 'SHORTJPREFIX1',
        last_doi_issued: '1000001'
      )
    end

    let!(:user) { FactoryGirl.create(:user) }
    let(:orcid_account) { user.orcid_account }

    it 'calls update profile' do
      expect(loader).to receive(:load)
      expect(Journal).to receive(:find) { journal }
      worker.perform(journal.id)
    end
  end
end
