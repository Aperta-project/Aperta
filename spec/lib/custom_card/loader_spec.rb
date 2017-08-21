require 'rails_helper'

describe CustomCard::Loader do
  let(:custom_card_loader) { CustomCard::Loader }
  let(:card_configuration) { CustomCard::Configurations::Sampler }

  before do
    # let each test stub out the available card configurations
    allow(custom_card_loader).to receive(:card_configuration_klasses).and_return(Array.new(configurations))
  end

  describe ".load" do
    let!(:journal) { FactoryGirl.create(:journal) }
    let(:configurations) { [card_configuration] }

    it "calls the Factory for a given configuration, for a given Journal" do
      expect_any_instance_of(CustomCard::Factory).to receive(:first_or_create).with(card_configuration).once
      custom_card_loader.load(card_configuration, journal: journal)
    end
  end

  describe ".load!" do
    let!(:journal) { FactoryGirl.create(:journal) }
    let(:configurations) { [card_configuration] }

    context "with a valid configuration" do
      it "calls the Factory for a given configuration, for a given Journal" do
        expect_any_instance_of(CustomCard::Factory).to receive(:first_or_create).with(card_configuration).once.and_return([Card.new])

        expect(
          custom_card_loader.load!(card_configuration, journal: journal).first
        ).to be_kind_of(Card)
      end
    end

    context "with an invalid configuration" do
      it "raises an error" do
        expect_any_instance_of(CustomCard::Factory).to receive(:first_or_create).with(card_configuration).once.and_return([])

        expect {
          custom_card_loader.load!(card_configuration, journal: journal)
        }.to raise_error(RuntimeError, /could not be loaded/)
      end
    end
  end

  describe ".all" do
    let!(:journals) { FactoryGirl.create_list(:journal, 2) }
    let(:configurations) { [card_configuration, card_configuration] }

    context "without a journal scope" do
      it "calls the Factory for each configuration, for each Journal in system" do
        expect(custom_card_loader).to receive(:load).with(card_configuration, journal: journals.first).twice
        expect(custom_card_loader).to receive(:load).with(card_configuration, journal: journals.second).twice
        custom_card_loader.all
      end
    end

    context "with a journal scope" do
      it "calls the Factory for each configuration, for each Journal in system" do
        expect(custom_card_loader).to receive(:load).with(card_configuration, journal: journals.first).twice
        custom_card_loader.all(journals: journals.first)
      end
    end
  end
end
