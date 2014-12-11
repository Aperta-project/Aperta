require 'spec_helper'

describe "Journal" do
  it "will be valid with default factory data" do
    journal = build(:journal)
    expect(journal).to be_valid
  end

  describe "DOI" do
    before do
      @journal = build(:journal)
      @journal.doi_publisher_prefix = "PPREFIX"
      @journal.doi_journal_prefix = "JPREFIX"
      @journal.last_doi_issued = "100001"
      @journal.save!
    end

    it "can save a DOI" do
      expect(@journal.doi_publisher_prefix).to eq "PPREFIX"
      expect(@journal.doi_journal_prefix).to eq "JPREFIX"
      expect(@journal.last_doi_issued).to eq "100001"
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
        @journal = build(:journal)
        @journal.doi_publisher_prefix = "PPREFIX"
        @journal.doi_journal_prefix = "JPREFIX"
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
