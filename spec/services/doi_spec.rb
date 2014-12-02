require 'spec_helper'

describe Doi do

  describe ".valid?" do
    context "with a doi" do
      let(:doi) { 'any/thing.1' }
      it "returns true" do
        expect(described_class.valid? doi).to eq true
      end
    end

    context "without a doi" do
      it "returns false" do
        expect(described_class.valid? nil).to eq false
      end
    end

    context "with an invalid doi" do
      it "returns false" do
        expect(described_class.valid? "monkey").to eq false
      end
    end
  end

  describe "initialization" do
    context "with a journal" do
      let(:journal) { create :journal }
      it "assigns a journal as @journal" do
        expect(described_class.new(journal: journal).journal).to eq journal
      end
    end

    context "without a journal" do
      it "raises an exception" do
        expect {
          described_class.new(nil)
        }.to raise_error ArgumentError, "missing keyword: journal"
      end
    end
  end

  describe "method delegation" do
    context "with a journal" do
      let(:journal) { create :journal }
      describe "last_doi_issued" do
        it "deltgates to journal" do
          expect(journal.respond_to? :last_doi_issued).to eq true
          journal
          mock_journal = instance_double("Journal", :last_doi_issued => 123)
          expect(mock_journal).to receive(:last_doi_issued)
          expect(
            described_class.new(journal: mock_journal).last_doi_issued
          ).to eq 123
        end
      end
    end
  end

  describe "#to_s" do
    context "with a publisher_prefix and publisher suffix" do
      let(:journal) { create :journal }
      xit "returns a properly-formatted doi string" do
        expect(described_class.new(journal: journal).to_s).to eq false
      end
    end
  end
end
