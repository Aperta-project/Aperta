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
      @journal.doi_start_number = "100001"
      @journal.save!
    end

    it "can save a DOI" do
      expect(@journal.doi_publisher_prefix).to eq "PPREFIX"
      expect(@journal.doi_journal_prefix).to eq "JPREFIX"
      expect(@journal.doi_start_number).to eq "100001"
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

  describe ".next_doi!" do
    describe "journals without DOI" do
      let(:journal) { Journal.new() }

      it "returns nil" do
        expect(journal.next_doi!).to eq(nil)
      end
    end

    describe "journal with DOI" do
      let(:journal) do
        Journal.new(doi_publisher_prefix: "PPREFIX",
                    doi_journal_prefix: "JPREFIX",
                    doi_start_number: "100001")

      end

      it "returns the new valid DOI" do
        expect(journal.next_doi!).to eq("PPREFIX/JPREFIX.100002")
      end

      it "omits the journal prefix of it is not present" do
        journal.doi_journal_prefix = nil
        expect(journal.next_doi!).to eq("PPREFIX/100002")
      end

      it "updates the doi_start_number" do
        journal.next_doi!
        expect(journal.doi_start_number).to eq("100002")
      end
    end

  end
end
