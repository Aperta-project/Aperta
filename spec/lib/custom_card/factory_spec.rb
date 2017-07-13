require 'rails_helper'

describe CustomCard::Factory do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:custom_card_factory) { CustomCard::Factory.new(journal: journal) }
  let(:card_configuration) { CustomCard::Configurations::CoverLetter }

  before do
    allow(card_configuration).to receive(:xml_content).and_return(
       <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <card required-for-submission="false" workflow-display-only="false">
          <content content-type="text">
            <text>Some card content</text>
          </content>
        </card>
        XML
      )
  end

  it "creates a new card" do
    expect {
      custom_card_factory.create(card_configuration)
    }.to change { Card.count }.by(1)
  end

  it "creates a new card content" do
    expect {
      custom_card_factory.create(card_configuration)
    }.to change { CardContent.count }.by(1)
  end

  describe "publishing the card" do
    context "configuration specifies #publish=true" do
      before do
        allow(card_configuration).to receive(:publish).and_return(true)
      end

      it "publishes the new card" do
        custom_card_factory.create(card_configuration)
        expect(Card.last.published?).to eq(true)
      end
    end

    context "configuration specifies #publish=false" do
      before do
        allow(card_configuration).to receive(:publish).and_return(false)
      end

      it "publishes the new card" do
        custom_card_factory.create(card_configuration)
        expect(Card.last.published?).to eq(false)
      end
    end
  end

  context "card with same name already exists" do
    let!(:existing_card) {
      FactoryGirl.create(:card, :versioned, journal: journal, name: card_configuration.name)
    }

    it "does not create a new card" do
      expect {
        custom_card_factory.create(card_configuration)
      }.to_not change { Card.count }
    end

    it "does not update existing card" do
      expect {
        custom_card_factory.create(card_configuration)
      }.to_not change { existing_card }
    end
  end

  describe "assigning default permissions" do
    let(:role_name) { Role::BILLING_ROLE }
    let!(:role) do
      # create a default journal role
      FactoryGirl.create(:role, journal: journal, name: role_name)
    end

    context "with no excluded permissions defined by configuration" do
      before do
        allow(card_configuration).to receive(:excluded_view_permissions).and_return(nil)
        allow(card_configuration).to receive(:excluded_edit_permissions).and_return(nil)
      end

      it "has all journal permissions" do
        expect {
          custom_card_factory.create(card_configuration)
        }.to change { role.permissions.count }.from(0).to(3)
      end
    end

    context "with excluded VIEW permissions defined by configuration" do
      before do
        allow(card_configuration).to receive(:excluded_view_permissions).and_return(role_name)
        allow(card_configuration).to receive(:excluded_edit_permissions).and_return(nil)
      end

      it "has no view permissions for excluded role" do
        custom_card_factory.create(card_configuration)
        expect(role.permissions.where(action: "view").count).to eq(0)
        expect(role.permissions.where(action: "edit").count).to eq(1)
      end
    end

    context "with excluded EDIT permissions defined by configuration" do
      before do
        allow(card_configuration).to receive(:excluded_view_permissions).and_return(nil)
        allow(card_configuration).to receive(:excluded_edit_permissions).and_return(role_name)
      end

      it "has no edit permissions for excluded role" do
        custom_card_factory.create(card_configuration)
        expect(role.permissions.where(action: "edit").count).to eq(0)
        expect(role.permissions.where(action: "view").count).to eq(2)
      end
    end
  end
end
