require 'rails_helper'

describe Journal do
  it "will be valid with default factory data" do
    journal = build(:journal)
    expect(journal).to be_valid
  end

  context "that has DOI information" do
    before do
      @journal = build(:journal)
    end

    it "still valid" do
      expect(@journal.doi_publisher_prefix).to eq nil
      expect(@journal.doi_journal_prefix).to eq nil
      expect(@journal.last_doi_issued).to eq "0"
      expect(@journal.save!).to eq true
    end
  end

  describe "#destroy" do
    context "with papers" do
      let!(:journal) { FactoryGirl.create(:journal, :with_paper) }

      it "throws error" do
        expect { journal.destroy }.to_not change { Journal.count }
        expect(journal.errors[:base].to_s).to match(/must be destroyed/)
      end
    end

    context "without papers" do
      let!(:journal) { FactoryGirl.create(:journal) }

      it "destroys journal" do
        expect { journal.destroy }.to change { Journal.count }.by(-1)
      end
    end
  end

  describe '#last_doi_issued' do
    subject(:journal) { FactoryGirl.build(:journal) }
    context 'and the journal is a new record' do
      before do
        expect(journal.new_record?).to be(true)
      end

      it 'allows last_doi_issued to be set' do
        expect do
          journal.last_doi_issued = '12345'
          journal.save!
          journal.reload
        end.to change { journal.last_doi_issued }.to eq('12345')
      end
    end

    context 'and the journal is not a new record' do
      before { journal.save! }

      it 'does not allow last_doi_issued to be set' do
        expect do
          journal.update!(last_doi_issued: '98765')
          journal.reload
        end.to_not change { journal.last_doi_issued }
      end
    end
  end

  describe "#next_doi_number!" do
    let(:journal) { FactoryGirl.create(:journal) }

    it "increments last_doi_issued and returns that value" do
      next_doi = nil
      expect do
        next_doi = journal.next_doi_number!
      end.to change { journal.last_doi_issued.to_i }.by 1
      expect(next_doi).to eq journal.last_doi_issued
    end
  end

  describe "DOI" do
    before do
      @journal = build(:journal, :with_doi)
      @journal.save!
    end

    it "can be created" do
      expect(@journal.doi_publisher_prefix).to be_truthy
      expect(@journal.doi_journal_prefix).to   be_truthy
      expect(@journal.last_doi_issued).to      be_truthy
    end

    it "will not save invalid DOI publisher prefix" do
      @journal.doi_publisher_prefix = "#"

      expect {
        @journal.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "will not save invalid DOI journal prefix" do
      @journal.doi_journal_prefix = "miss/2"

      expect {
        @journal.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    describe "additional Journals" do
      before do
        existing_journal = Journal.last

        @journal = build(:journal)
        @journal.doi_publisher_prefix = existing_journal.doi_publisher_prefix
        @journal.doi_journal_prefix = existing_journal.doi_journal_prefix
      end

      it "does not accept duplicate journal prefixes" do
        expect {
          @journal.save!
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "without DOI information" do
    it "can still be created" do
      journal = build(:journal)
      expect(journal).to be_valid
      journal.save!
    end
  end
end
