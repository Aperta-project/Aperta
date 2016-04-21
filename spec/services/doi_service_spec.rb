require 'rails_helper'

describe DoiService do

  let(:journal_doi) do
    [journal[:doi_publisher_prefix], journal[:doi_journal_prefix]].join('/') + "." + journal[:first_doi_number]
  end

  describe ".valid?" do
    context "with a doi" do
      let(:doi) { 'any.thing/thing.1' }
      it "returns true" do
        expect(described_class.valid? doi).to eq true
        expect(described_class.valid? "10.10.1038/nphys1170").to eq true
        expect(described_class.valid? "10.1002/0470841559.ch1").to eq true
        expect(described_class.valid? "10.1594/PANGAEA.726855").to eq true
        expect(described_class.valid? "10.1594/GFZ.GEOFON.gfz2009kciu").to eq true
        expect(described_class.valid? "10.1594/PANGAEA.667386").to eq true
        expect(described_class.valid? "10.3207/2959859860").to eq true
        expect(described_class.valid? "10.3866/PKU.WHXB201112303").to eq true
        expect(described_class.valid? "10.3972/water973.0145.db").to eq true
        expect(described_class.valid? "10.7666/d.y351065").to eq true
        expect(described_class.valid? "10.11467/isss2003.7.1_11").to eq true
        expect(described_class.valid? "10.7875/leading.author.2.e008").to eq true
        expect(described_class.valid? "10.1430/8105").to eq true
        expect(described_class.valid? "10.1392/BC1.0").to eq true
        expect(described_class.valid? "10.1000/182").to eq true
        expect(described_class.valid? "10.1234/joe.jou.1516").to eq true
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
    context "with nil argument passed as a journal" do
      it "raises an exception" do
        expect {
          described_class.new(journal: nil)
        }.to raise_error ArgumentError, "Journal is required"
      end
    end
  end

  describe "#first_doi" do
    context "with a publisher_prefix/journal_prefix.first_doi_number" do
      let(:journal) { create :journal }

      it "returns a properly-formatted doi string" do
        expect(described_class.new(journal: journal).first_doi).to eq journal_doi
      end
    end
  end

  describe "#last_doi" do
    let(:journal) do
      create :journal,
             doi_publisher_prefix: "10.1371",
             doi_journal_prefix: "pwom"
    end
    let(:doi_service) { DoiService.new(journal: journal) }

    context "there are papers with the journal" do
      let!(:first_paper) do
        create(:paper, journal: journal, doi: "10.1371/pwom.1")
      end
      let!(:last_paper) do
        create(:paper, journal: journal, doi: "10.1371/pwom.2")
      end
      let!(:other_journals_paper) do
        create(:paper, journal: journal, doi: "10.1371/pzzz.3")
      end

      it "returns the highest doi with the journal's base doi" do
        expect(last_paper.doi).to be_present
        expect(doi_service.last_doi).to eq last_paper.doi
      end
    end

    context "there are no papers with the journal" do
      let!(:other_journals_paper) do
        create(:paper, journal: journal, doi: "10.1371/pzzz.3")
      end

      it "returns nil when it finds no papers" do
        expect(doi_service.last_doi).to be_nil
      end
    end
  end

  describe "#next_doi" do
    let(:journal) do
      create :journal,
             doi_publisher_prefix: "10.1371",
             doi_journal_prefix: "pwom",
             first_doi_number: "000001"
    end
    let(:doi_service) { DoiService.new(journal: journal) }

    context "there are papers with the journal" do
      let!(:paper) do
        create(:paper, journal: journal, doi: "10.1371/pwom.0001")
      end

      it "returns the next available doi" do
        expect(doi_service.next_doi).to eq "10.1371/pwom.0002"
      end
    end

    context "there are no papers with the journal's base doi" do
      it "returns the first doi for the journal's doi pattern" do
        expect(doi_service.last_doi).to be_nil
        expect(doi_service.next_doi).to eq '10.1371/pwom.000001'
      end
    end

    context "there is a paper with a maximal doi" do
      let!(:paper) do
        create(:paper, journal: journal, doi: "10.1371/pwom.9999")
      end

      it "fails" do
        expect do
          doi_service.next_doi
        end.to raise_error DoiService::DoiLengthChanged
      end
    end
  end
end
