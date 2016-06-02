require 'rails_helper'

describe DoiService do

  let(:journal_doi) do
    "#{journal.doi_publisher_prefix}/journal.#{journal.doi_journal_prefix}.#{journal.last_doi_issued}"
  end

  describe ".valid?" do
    context "with a doi" do
      let(:doi) { 'any.thing/journal.thing.1' }
      it "returns true" do
        expect(described_class.valid? doi).to eq true
        expect(described_class.valid? "10.10.1038/journal.nphys1170").to eq true
        expect(described_class.valid? "10.1002/journal.0470841559.ch1").to eq true
        expect(described_class.valid? "10.1594/journal.PANGAEA.726855").to eq true
        expect(described_class.valid? "10.1594/journal.GFZ.GEOFON.gfz2009kciu").to eq true
        expect(described_class.valid? "10.1594/journal.PANGAEA.667386").to eq true
        expect(described_class.valid? "10.3207/journal.2959859860").to eq true
        expect(described_class.valid? "10.3866/journal.PKU.WHXB201112303").to eq true
        expect(described_class.valid? "10.3972/journal.water973.0145.db").to eq true
        expect(described_class.valid? "10.7666/journal.d.y351065").to eq true
        expect(described_class.valid? "10.11467/journal.isss2003.7.1_11").to eq true
        expect(described_class.valid? "10.7875/journal.leading.author.2.e008").to eq true
        expect(described_class.valid? "10.1430/journal.8105").to eq true
        expect(described_class.valid? "10.1392/journal.BC1.0").to eq true
        expect(described_class.valid? "10.1000/journal.182").to eq true
        expect(described_class.valid? "10.1234/journal.joe.jou.1516").to eq true
      end
    end

    context "without a doi" do
      it "returns false" do
        expect(described_class.valid? nil).to eq false
      end
    end

    context "with an invalid doi" do
      it "returns false" do
        expect(described_class.valid? "10.1000/182/12").to eq false
        expect(described_class.valid? "monkey").to eq false
      end
    end
  end

  describe "initialization" do
    context "with a journal" do
      let(:journal) { create :journal, :with_doi }
      it "assigns a journal as @journal" do
        expect(described_class.new(journal: journal).journal).to eq journal
      end
    end

    context "with nil argument passed as a journal" do
      it "raises an exception" do
        expect {
          described_class.new(journal: nil)
        }.to raise_error ArgumentError, "Journal is required"
      end
    end

  end

  describe "method delegation" do
    context "with a journal" do
      let!(:journal) { Journal.new }

      def ensure_delegated method
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
        expect(described_class.new(journal: journal).to_s).to eq journal_doi
      end
    end
  end

  describe "#next_doi!" do
    let(:journal) { create :journal, :with_doi }
    let(:doi_service) { DoiService.new(journal: journal) }

    it "assigns the next available doi to the journal" do
      last_doi_issued = journal.last_doi_issued
      expect {
        doi_service.next_doi!
      }.to change(journal, :last_doi_issued)
        .from(last_doi_issued)
        .to(last_doi_issued.succ)
    end

    context "when assignment is successful" do
      it "returns true" do
        expect(doi_service.next_doi!).to eq journal_doi
      end
    end

    context "when doi assignment fails" do
      context "when the publisher prefix is not set" do
        it "returns nil" do
          journal.update_attributes(doi_publisher_prefix: nil)
          expect(doi_service.next_doi!).to eq nil
        end
      end

      context "when the journal prefix is not set" do
        it "returns nil" do
          journal.update_attributes(doi_journal_prefix: nil)
          expect(doi_service.next_doi!).to eq nil
        end
      end
    end

  end

end
