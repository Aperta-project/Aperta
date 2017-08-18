require 'rails_helper'

describe CustomCard::Migrator do
  let(:answer) { FactoryGirl.build(:answer) }
  let(:task) { answer.task }
  let(:content) { task.card.latest_published_card_version.card_contents.first }

  before do
    task.card.tap do |c|
      c.name = task.type
      c.publish!('Initial version')
    end
    answer.update(card_content: content)
  end

  context 'replacement card was not generated' do
    it 'does not migrate task card version' do
      expect {
        CustomCard::Migrator.new(legacy_task_klass_name: task.type, card_name: task.title).migrate
      }.to_not change { Task.find(task.id).card_version_id }
    end

    it 'does not delete legacy card' do
      expect {
        CustomCard::Migrator.new(legacy_task_klass_name: task.type, card_name: task.title).migrate
        Card.find(task.card.id)
      }.to_not raise_error
    end

    it 'does not migrate answer card content id' do
      expect {
        CustomCard::Migrator.new(legacy_task_klass_name: task.type, card_name: task.title).migrate
      }.to_not change { answer.reload.card_content_id }
    end
  end

  context 'replacement card was generated' do
    before do
      Journal.pluck(:id).each do |journal_id|
        new_card = Card.create_initial_draft!(name: task.title, journal_id: journal_id)
        new_card.reload.publish!('Initial version')
        new_card.latest_published_card_version.card_contents.update_all(ident: content.ident)
      end
    end

    it 'migrates task card version' do
      expect {
        CustomCard::Migrator.new(legacy_task_klass_name: task.type, card_name: task.title).migrate
      }.to change { Task.find(task.id).card_version_id }
    end

    it 'migrates answer card content id' do
      expect {
        CustomCard::Migrator.new(legacy_task_klass_name: task.type, card_name: task.title).migrate
      }.to change { answer.reload.card_content_id }
    end

    it 'deletes the legacy card' do
      expect {
        CustomCard::Migrator.new(legacy_task_klass_name: task.type, card_name: task.title).migrate
        Card.find(task.card.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
