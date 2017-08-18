require 'rails_helper'

describe CustomCard::Factory do
  let!(:journal) { FactoryGirl.create(:journal) }
  let(:custom_card_factory) { CustomCard::Factory.new(journal: journal) }

  # fake custom card config to use for testing
  let(:card_configuration) do
    Class.new(CustomCard::Configurations::Base) do
      def self.name
        "A Test Card"
      end

      def self.xml_content
        <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
          <card required-for-submission="false" workflow-display-only="false">
            <content content-type="text">
              <text>Some card content</text>
            </content>
          </card>
        XML
      end
    end
  end

  it "creates a new card" do
    expect {
      custom_card_factory.first_or_create(card_configuration)
    }.to change { Card.count }.by(1)
  end

  it "creates a new card content" do
    expect {
      custom_card_factory.first_or_create(card_configuration)
    }.to change { CardContent.count }.by(1)
  end

  describe "publishing the card" do
    context "configuration specifies #publish=true" do
      before do
        allow(card_configuration).to receive(:publish).and_return(true)
      end

      it "publishes the new card" do
        custom_card_factory.first_or_create(card_configuration)
        expect(Card.last.published?).to eq(true)
      end
    end

    context "configuration specifies #publish=false" do
      before do
        allow(card_configuration).to receive(:publish).and_return(false)
      end

      it "publishes the new card" do
        custom_card_factory.first_or_create(card_configuration)
        expect(Card.last.published?).to eq(false)
      end
    end
  end

  context "card with same name already exists" do
    let!(:existing_card) do
      FactoryGirl.create(:card, :versioned, journal: journal, name: card_configuration.name)
    end

    it "does not create a new card" do
      expect {
        custom_card_factory.first_or_create(card_configuration)
      }.to_not change { Card.count }
    end

    it "does not update existing card" do
      expect {
        custom_card_factory.first_or_create(card_configuration)
      }.to_not change { existing_card }
    end
  end

  describe "assigning default permissions" do
    let(:role_name) { Role::BILLING_ROLE }
    let!(:role) do
      # create a default journal role
      FactoryGirl.create(:role, journal: journal, name: role_name)
    end

    context "with no permissions defined by configuration" do
      before do
        allow(card_configuration).to receive(:view_role_names).and_return(nil)
        allow(card_configuration).to receive(:edit_role_names).and_return(nil)
      end

      it "has all journal permissions" do
        custom_card_factory.first_or_create(card_configuration)
        expect(role.permissions.count).to eq(0)
      end
    end

    context "with :ALL permissions defined by configuration" do
      before do
        allow(card_configuration).to receive(:view_role_names).and_return(:all)
        allow(card_configuration).to receive(:edit_role_names).and_return(:all)
      end

      it "has view and edit permissions defined" do
        custom_card_factory.first_or_create(card_configuration)
        expect(role.permissions.where(action: "view").count).to eq(2)
        expect(role.permissions.where(action: "edit").count).to eq(1)
      end
    end

    context "with VIEW permissions defined by configuration" do
      before do
        allow(card_configuration).to receive(:view_role_names).and_return(role_name)
        allow(card_configuration).to receive(:edit_role_names).and_return(nil)
      end

      it "has only view permissions defined (one for Card, one for CardVersion)" do
        custom_card_factory.first_or_create(card_configuration)
        expect(role.permissions.where(action: "view").count).to eq(2)
        expect(role.permissions.where(action: "edit").count).to eq(0)
      end
    end

    context "with EDIT permissions defined by configuration" do
      before do
        allow(card_configuration).to receive(:view_role_names).and_return(nil)
        allow(card_configuration).to receive(:edit_role_names).and_return(role_name)
      end

      it "has only edit permissions defined" do
        custom_card_factory.first_or_create(card_configuration)
        expect(role.permissions.where(action: "edit").count).to eq(1)
        expect(role.permissions.where(action: "view").count).to eq(0)
      end
    end
  end
end
