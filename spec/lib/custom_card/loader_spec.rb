require 'rails_helper'

describe CustomCard::Loader do
  let(:custom_card_loader) { CustomCard::Loader }
  let(:card_configuration) { CustomCard::Configurations::CoverLetter }

  before do
    # let each test stub out the available card configurations
    allow(custom_card_loader).to receive(:card_configuration_klasses).and_return(Array.new(configurations))
  end

  describe ".load" do
    let!(:journal) { FactoryGirl.create(:journal) }
    let(:configurations) { [card_configuration] }

    it "calls the Factory for a given configuration, for a given Journal" do
      expect_any_instance_of(CustomCard::Factory).to receive(:create).with(card_configuration).once
      custom_card_loader.load(card_configuration, journal: journal)
    end
  end

  describe ".all" do
    let!(:journals) { FactoryGirl.create_list(:journal, 2) }
    let(:configurations) { [card_configuration, card_configuration] }

    it "calls the Factory for each configuration, for each Journal in system" do
      expect(custom_card_loader).to receive(:load).with(card_configuration, journal: journals.first).twice
      expect(custom_card_loader).to receive(:load).with(card_configuration, journal: journals.second).twice
      custom_card_loader.all
    end
  end
end
