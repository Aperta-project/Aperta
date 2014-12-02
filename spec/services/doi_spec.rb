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
      let(:journal) { Journal.new }

      def ensure_delegated method
        # this is here as a work around for flaky tests
        # associated with instance_double verifying Journal#last_doi_issued
        expect(journal.respond_to? method).to eq true
        mock_journal = instance_double(Journal, method => 123)
        expect(mock_journal).to receive(method)
        expect(
          described_class.new(journal: mock_journal).public_send method
        ).to eq 123
      end

      describe "last_doi_issued" do
        it "delegates to journal" do
          ensure_delegated :last_doi_issued
        end

        describe "doi_publisher_prefix" do
          it "delegates to journal" do
            ensure_delegated :doi_publisher_prefix
          end
        end

        describe "doi_journal_prefix" do
          it "delegates to journal" do
            ensure_delegated :doi_journal_prefix
          end
        end
      end
    end
  end

  describe "#to_s" do
    context "with a publisher_prefix/journal_prefix.next_doi_id" do
      let(:journal) { create :journal }

      it "returns a properly-formatted doi string" do
        expected = [journal[:doi_publisher_prefix],
                    journal[:doi_journal_prefix]].join('/') +
                    "." +
                    journal[:last_doi_issued].succ
        expect(described_class.new(journal: journal).to_s).to eq expected
      end
    end
  end
end
