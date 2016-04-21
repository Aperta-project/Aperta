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

  describe "DOI" do
    before do
      @journal = build(:journal)
      @journal.save!
    end

    it "can be created" do
      expect(@journal.doi_publisher_prefix).to be_truthy
      expect(@journal.doi_journal_prefix).to be_truthy
      expect(@journal.first_doi_number).to be_truthy
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
