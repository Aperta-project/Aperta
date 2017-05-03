require 'rails_helper'

describe CardArchiver do
  context ".archive" do
    it "sets the archived_at date of the card" do
      card = FactoryGirl.create(:card, state: "published")
      expect(card.archived_at).to be_nil
      CardArchiver.archive(card)
      expect(card.reload.archived_at).to be_present
    end

    it "does not change the date on already archived cards" do
      card = FactoryGirl.create(:card, :archived)
      expect { CardArchiver.archive(card) }.to_not change(card, :archived_at)
    end

    context "removing TaskTemplate records" do
      let(:card) { FactoryGirl.create(:card) }
      let!(:card_template) { FactoryGirl.create(:task_template, card: card, journal_task_type: nil) }
      let!(:other_template) { FactoryGirl.create(:task_template) }
      it "deletes any TaskTemplates that belong to the archived card" do
        expect { CardArchiver.archive(card) }.to change(TaskTemplate, :count).by(-1)
        expect(TaskTemplate.find_by(id: card_template.id)).to be_nil
      end
    end
  end
end
