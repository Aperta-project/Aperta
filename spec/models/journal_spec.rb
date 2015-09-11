require 'rails_helper'

describe "Journal" do

  it "will be valid with default factory data" do
    journal = build(:journal)
    expect(journal).to be_valid
  end

  context "without DOI" do
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

  describe "DOI" do
    before do
      @journal = build(:journal, :with_doi)
      @journal.save!
    end

    it "can save a DOI" do
      expect(@journal.doi_publisher_prefix).to include "PPREFIX"
      expect(@journal.doi_journal_prefix).to include "JPREFIX"
      expect(@journal.last_doi_issued).to include "10000"
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

    describe "more Journals" do
      it "which do not have DOI set" do
        journal = build(:journal)
        expect(journal).to be_valid
        journal.save!

        journal = build(:journal)
        expect(journal).to be_valid
        journal.save!
      end
    end
  end
end
